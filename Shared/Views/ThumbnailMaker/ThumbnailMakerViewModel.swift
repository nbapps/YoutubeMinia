//
//  ThumbnailMakerViewModel.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation
import Combine
import SwiftUI
import UniformTypeIdentifiers
#if canImport(KeyboardShortcuts)
import KeyboardShortcuts
#endif

enum YMViewModelError: Error {
    case missingHost
    case notAYoutubeURL
    case foundYouTubeChannelCustomUrl
    case notAYoutubeVideoURL
    case notAYoutubeChannelURL
    case missingVideoId
    case missingChannelId
    
    case missingResponse
    case noImage
}

final class ThumbnailMakerViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService()
    private let notificationService = NotificationService()
    #if os(iOS)
    private let imageSaverService = ImageSaverService()
    #endif
    static let shared = ThumbnailMakerViewModel()
    static let preview = ThumbnailMakerViewModel()
    
    @Published var lastVideoURlStr: String?
    @Published var videoId: String?
    @Published var videoURlStr: String = ""// Dont use anymore this key because it's not necessary with DB // UserDefaults.appGroup.videoURlStr
    @Published var showDuration: Bool = UserDefaults.appGroup.showDuration
    @Published var showChannelIcon: Bool = UserDefaults.appGroup.showChannelIcon
    @Published var showChannelName: Bool = UserDefaults.appGroup.showChannelName
    @Published var showChannelCount: Bool = UserDefaults.appGroup.showChannelCount
    @Published var showViewCount: Bool = UserDefaults.appGroup.showViewCount
    @Published var showPublishDate: Bool = UserDefaults.appGroup.showPublishDate
    @Published var showProgress: Bool = UserDefaults.appGroup.showProgress
    @Published var lastProgress: Double = UserDefaults.appGroup.lastProgress
    @Published var isDarkTheme: Bool = UserDefaults.appGroup.isDarkTheme
    @Published var thumbnailCornerRadius: Double = UserDefaults.appGroup.thumbnailCornerRadius
    @Published var thumbnailPadding: Double = UserDefaults.appGroup.thumbnailPadding
    
    @Published var applySavedSettingsOnSelectFromHistory: Bool = UserDefaults.appGroup.applySavedSettingsOnSelectFromHistory
    
    @Published var exportSize: ExportScale = UserDefaults.appGroup.exportSize
    
    @Published var ymThumbnailData: YMThumbnailData?
    @Published var videoThumbnail: Image?
    @Published var channelThumbnail: Image?
    
    @Published var isFetching = false
    @Published var exportAfterOnDrop = false
    
    @Published var selectedTab = Tabs.maker
    
    private let referenceWidth: CGFloat = 350
    
    var onExportSuccess: (() -> Void)?
    var isValidURL = false
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    init() {
        udObservers()
        observeUbiquitousKeyValueStore()

        if ProcessInfo.runForPreview {
            let moc = YMThumbnailData.moc
            ymThumbnailData = moc
            Task { @MainActor in
                try? await fetchThumbnails(videoThumbnailUrl: moc.videoThumbnailUrl, channelThumbnailUrl: moc.channelThumbnailUrl)
            }
        }
        
        $videoURlStr
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .compactMap { $0.isNotEmpty ? $0 : nil }
            .compactMap { [weak self] url in self?.checkIfURLIsValid(urlStr: url) }
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self else { return }
                Task { @MainActor in
                    do {
                        try await self.fetch()
                    } catch {
                        print(error)
                    }
                }
            }
            .store(in: &cancellables)
        
        $showProgress
            .compactMap { $0 ? $0 : nil }
            .sink { [weak self] newValue in
                if self?.lastProgress == 0 {
                    self?.lastProgress = 0.5
                }
            }
            .store(in: &cancellables)
        
        $lastProgress
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.showProgress = newValue != 0
            }
            .store(in: &cancellables)
#if os(macOS)
        KeyboardShortcuts.onKeyUp(for: .fetchThumbnail) { [weak self] in
            self?.pastUrlAndFetchIfPossible()
        }
        
        KeyboardShortcuts.onKeyUp(for: .copyLastFetch) { [weak self] in
            self?.copyPreviousThumbnailIfExisting()
        }
#endif
    }
    
    func pastUrlAndFetchIfPossible() {
        Task { @MainActor in
            guard let clipboardString = Clipboard.general.getString() else { return }
            guard let urlStr = checkIfURLIsValid(urlStr: clipboardString) else { return }
            self.videoURlStr = urlStr
            try? await self.fetch()

            copy(renderThumbnail())
        }
    }
    
    @MainActor
    func renderThumbnail() -> AppImage? {
        guard let thumbnailData = ymThumbnailData else { return nil }
        let width: CGFloat = 600
        let rendered = ThumbnailView(thumbnailData: thumbnailData, width: width)
            .environmentObject(self)
            .frame(width: width)
//            .padding()
            .getScaledImage(scale: exportSize.scale)

        return rendered.appImage
    }
    
    func copyPreviousThumbnailIfExisting() {
        Task { @MainActor in
            guard let image = renderThumbnail() else { return }
            copy(image)
        }
    }
    
    @MainActor
    func fetch() async throws {
        defer {
            print("fetch done")
            isFetching = false
        }
        guard videoURlStr.isNotEmpty else { return }
        guard let videoURlStr = checkIfURLIsValid(urlStr: videoURlStr) else { return }
        
        guard lastVideoURlStr != videoURlStr else { return }
        
        do {
            if let videoId = try extractVideoId(from: videoURlStr),
               let ytVideoUrl = Config.videoURL(for: videoId) {
                try await fetchVideo(for: ytVideoUrl, videoId: videoId)
            } else if let channelCustomUrl = try extractChannelCustomUrl(from: videoURlStr),
                      let channelUrl = Config.channelURL(channelCustomUrl: channelCustomUrl) {
                try await fetchChannel(for: channelUrl, channelCustomUrl: channelCustomUrl)
            }
        } catch let error as YMViewModelError {
            guard error == .foundYouTubeChannelCustomUrl else { throw error }
            guard let channelCustomUrl = try extractChannelCustomUrl(from: videoURlStr),
                  let channelUrl = Config.channelURL(channelCustomUrl: channelCustomUrl) else { throw error }
            try await fetchChannel(for: channelUrl, channelCustomUrl: channelCustomUrl)
        } catch {
            throw error
        }
    }
    
    @MainActor
    func fetchVideo(for ytVideoUrl: URL, videoId: String) async throws {
        defer {
            print("fetchVideo done")
            isFetching = false
        }

        guard lastVideoURlStr != videoURlStr else { return }

        ymThumbnailData = nil
        videoThumbnail = nil
        channelThumbnail = nil
        isFetching = true
        
        self.videoId = videoId
        self.lastVideoURlStr = videoURlStr
        
        print("start fetchVideo")
        let videoResponse: YTDecodable = try await networkService.fetch(from: ytVideoUrl)
        guard let videoItem = videoResponse.items.first,
              let videoSnippet = videoItem.snippet,
              let videoStatistics = videoItem.statistics,
              let thumbnails = videoSnippet.thumbnails,
              let videoThumbnails = thumbnails.maxres?.url,
              let channelId = videoSnippet.channelId
        else { throw YMViewModelError.missingResponse }
        
        guard let ytChannelUrl = Config.channelURL(for: channelId)else { throw YMViewModelError.missingChannelId }
        
        let channelResponse: YTDecodable = try await networkService.fetch(from: ytChannelUrl)
        
        guard let channelItem = channelResponse.items.first,
              let channelSnippet = channelItem.snippet,
              let channelStatistics = channelItem.statistics,
              let channelThumbnails = channelSnippet.thumbnails?.medium?.url
        else { throw YMViewModelError.missingResponse }
        
        guard let videoThumbnailUrl = URL(string: videoThumbnails),
              let channelThumbnailUrl = URL(string: channelThumbnails),
              let videoTitle = videoSnippet.title,
              let channelTitle = channelSnippet.title,
              let videoDuration = videoItem.contentDetails?.duration,
              let publicationDate = videoSnippet.publishedAt,
              let publicationDate = ISO8601DateFormatter().date(from: publicationDate)
        else { throw YMViewModelError.missingResponse }
        
        let thumbnailData = YMThumbnailData(
            videoURL: ytVideoUrl,
            videoThumbnailUrl: videoThumbnailUrl,
            channelThumbnailUrl: channelThumbnailUrl,
            videoTitle: videoTitle,
            channelTitle: channelTitle,
            viewCount: videoStatistics.viewCount ?? "0",
            channelCount: channelStatistics.subscriberCount ?? "0",
            videoDuration: videoDuration.formattedVideoDuration(),
            publicationDate: publicationDate
        )
        
        self.ymThumbnailData = thumbnailData
        
        try await fetchThumbnails(
            videoThumbnailUrl: videoThumbnailUrl,
            channelThumbnailUrl: channelThumbnailUrl
        )
        
        _ = try PreviousURL.add(
            videoURlStr,
            videoId: videoId,
            title: videoTitle,
            thumbnailUrlStr: videoThumbnailUrl.absoluteString
        )
        
        if exportAfterOnDrop {
            try exportToDownloads(thumbnailData: thumbnailData)
            exportAfterOnDrop = false
        }
        
        print("fetch video success")
    }
    
    @MainActor
    func fetchChannel(for channelUrl: URL, channelCustomUrl: String) async throws {
        defer {
            print("fetchChannel done")
            isFetching = false
        }
        
        guard lastVideoURlStr != videoURlStr else { return }
        
        ymThumbnailData = nil
        videoThumbnail = nil
        channelThumbnail = nil
        isFetching = true
        
        self.videoId = videoId
        self.lastVideoURlStr = videoURlStr
        
        print("start fetchChannel")
        let channelResponse: YTDecodable = try await networkService.fetch(from: channelUrl)
        guard let channelItem = channelResponse.items.first,
              let channelSnippet = channelItem.snippet,
              let channelStatistics = channelItem.statistics,
              let channelThumbnails = channelSnippet.thumbnails?.medium?.url
        else { throw YMViewModelError.missingResponse }
        
        guard
            let channelThumbnailUrl = URL(string: channelThumbnails),
            let channelTitle = channelSnippet.title,
            let channelCount = channelStatistics.subscriberCount
        else { throw YMViewModelError.missingResponse }
        
        try await fetchChannelThumbnail(channelThumbnailUrl: channelThumbnailUrl)

        let channelData = YMChannelData(
            channelUrl: channelUrl,
            channelThumbnailUrl: channelThumbnailUrl,
            channelTitle: channelTitle,
            channelCount: channelCount
        )
        
        print("fetch channel success")
    }
    
    @MainActor
    func fetchThumbnails(videoThumbnailUrl: URL, channelThumbnailUrl: URL) async throws {
        try await fetchVideoThumbnail(videoThumbnailUrl: videoThumbnailUrl)
        try await fetchChannelThumbnail(channelThumbnailUrl: channelThumbnailUrl)
    }
    
    @MainActor
    func fetchVideoThumbnail(videoThumbnailUrl: URL) async throws {
        let videoThumbnailData: Data = try await networkService.fetch(url: videoThumbnailUrl)
        if let img = AppImage(data: videoThumbnailData) {
            self.videoThumbnail = Image(appImage: img)
        }
    }
    
    @MainActor
    func fetchChannelThumbnail(channelThumbnailUrl: URL) async throws {
        let channelThumbnailData: Data = try await networkService.fetch(url: channelThumbnailUrl)
        if let img = AppImage(data: channelThumbnailData) {
            self.channelThumbnail = Image(appImage: img)
        }
    }
    
    @MainActor
    func copy(_ image: AppImage?) {
        guard let image else { return }
        image.copyImage()
        onExportSuccess?()
        Task {
            try? await notificationService.sendInstantNotification(
                urlStr: videoURlStr,
                message: String(localized: "!The thumbnail is in your clipboard")
            )
        }
    }
    
#if os(iOS)
    @MainActor
    func saveInPhotoLibrary(thumbnailData: YMThumbnailData) throws {
        // Mandatory to convert to png and re convert to image for keep transparency...
        guard let image = renderThumbnail(), let data = image.pngData(), let final = UIImage(data: data) else {
            throw YMViewModelError.noImage
        }
        
        imageSaverService.writeToPhotoAlbum(
            image: final,
            videoURlStr: videoURlStr,
            onExportSuccess: onExportSuccess
        )
    }
#endif
    
    @MainActor
    func exportToDownloads(thumbnailData: YMThumbnailData) throws {
        try exportThumbnail(
            image: renderThumbnail(),
            fileName: thumbnailData.videoTitle.formatFileName()
        )
    }
    
    @MainActor
    func exportThumbnail(image: AppImage?, fileName: String) throws {
        guard let image else {
            throw YMViewModelError.noImage
        }
        try FileManager.default.saveImageToDownloads(
            image: image,
            fileName: fileName,
            fileExt: "png"
        )
        onExportSuccess?()
        Task {
            try? await notificationService.sendInstantNotification(
                urlStr: videoURlStr,
                message: String(localized: "!The thumbnail has been saved in Downloads folder")
            )
        }
    }

    func applySettings(from previousURL: PreviousURL) {
        guard previousURL.urlStr.isNotEmpty else  {return }
        videoURlStr = previousURL.urlStr
        videoId = previousURL.videoId
        
        guard applySavedSettingsOnSelectFromHistory else { return }
        
        videoURlStr = previousURL.videoURlStr
        showDuration = previousURL.showDuration
        showChannelIcon = previousURL.showChannelIcon
        showChannelName = previousURL.showChannelName
        showChannelCount = previousURL.showChannelCount
        showViewCount = previousURL.showViewCount
        showPublishDate = previousURL.showPublishDate
        showProgress = previousURL.showProgress
        lastProgress = previousURL.lastProgress
        isDarkTheme = previousURL.isDarkTheme
        thumbnailCornerRadius = previousURL.thumbnailCornerRadius
        thumbnailPadding = previousURL.thumbnailPadding
    }
    
    @MainActor
    func configurationFile() -> SharableFile? {
        guard let ymThumbnailData else { return nil }
        return SharableFile(
            videoURlStr: videoURlStr,
            videoTitle: ymThumbnailData.videoTitle,
            showDuration: showDuration,
            showChannelIcon: showChannelIcon,
            showChannelName: showChannelName,
            showChannelCount: showChannelCount,
            showViewCount: showViewCount,
            showPublishDate: showPublishDate,
            showProgress: showProgress,
            lastProgress: lastProgress,
            isDarkTheme: isDarkTheme,
            thumbnailCornerRadius: thumbnailCornerRadius,
            thumbnailPadding: thumbnailPadding
        )
    }
    
    @MainActor
    func importeConfigurationFile(_ importedConfiguration: SharableFile) {
        videoURlStr = importedConfiguration.videoURlStr
        showDuration = importedConfiguration.showDuration
        showChannelIcon = importedConfiguration.showChannelIcon
        showChannelName = importedConfiguration.showChannelName
        showChannelCount = importedConfiguration.showChannelCount
        showViewCount = importedConfiguration.showViewCount
        showPublishDate = importedConfiguration.showPublishDate
        showProgress = importedConfiguration.showProgress
        lastProgress = importedConfiguration.lastProgress
        isDarkTheme = importedConfiguration.isDarkTheme
        thumbnailCornerRadius = importedConfiguration.thumbnailCornerRadius
        thumbnailPadding = importedConfiguration.thumbnailPadding
    }
    
    func mapValue(_ value: Double, fromRange: ClosedRange<Double>, toRange: ClosedRange<Double>) -> Double {
        let fromMin = fromRange.lowerBound
        let fromMax = fromRange.upperBound
        let toMin = toRange.lowerBound
        let toMax = toRange.upperBound
        
        let result = (value - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin
        return result.rounded(.up)
    }
    
    func checkIfURLIsValid(urlStr: String?) -> String? {
        var validURLStr: String?
        
        defer { isValidURL = validURLStr != nil }
        
        guard let urlStr else { return nil }
        guard let comp = URLComponents(string: urlStr) else { return nil }
        guard let host = comp.host else { return nil }
        guard host == "youtu.be" || host.contains("youtube.com") else { return nil }
        validURLStr = urlStr
        return validURLStr
    }
    
    func decodeURLFromBinaryPlist(_ data: Data) -> URL? {
        guard let decoded = try? PropertyListDecoder().decode([[String]].self, from: data),
              decoded.isNotEmpty, let plistData = decoded.first else { return nil }
        return plistData
            .compactMap {
                checkIfURLIsValid(urlStr: $0)
            }
            .compactMap { URL(string: $0) }
            .first
    }
    
    func processOnDrop(_ providers: [NSItemProvider]) -> Bool {
        providers.first?.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { [weak self] url, _ in
            guard let self else { return }
            guard let url else { return }
            DispatchQueue.main.async {
                if url.pathExtension == "yttm", let data = try? Data(contentsOf: url), let decoded = try? JSONDecoder().decode(SharableFile.self, from: data) {
                    self.importeConfigurationFile(decoded)
                    self.exportAfterOnDrop = true
                    return
                }
                
                if let data = try? Data(contentsOf: url) {
                    if self.ymThumbnailData == nil, let appImage = AppImage(data: data) {
                        self.videoThumbnail = Image(appImage: appImage)
                        return
                    } else if let validURL = self.decodeURLFromBinaryPlist(data) {
                        self.videoURlStr = validURL.absoluteString
                        self.exportAfterOnDrop = true
                        return
                    }
                }
                
                if let possibleYTUrl = try? String(contentsOf: url, encoding: .utf8),
                   let validURL = self.checkIfURLIsValid(urlStr: possibleYTUrl) {
                    self.videoURlStr = validURL
                    self.exportAfterOnDrop = true
                    return
                }
            }
        }
        return true
    }
}

extension ThumbnailMakerViewModel {
    func responsiveFontSize(currentWidth: CGFloat, referenceSize: CGFloat) -> CGFloat {
        let scaleFactor = currentWidth / referenceWidth
        return round(referenceSize * scaleFactor)
    }
    
    var innerCornerRadius: Double {
        mapValue(thumbnailCornerRadius, fromRange: 0...1, toRange: 8...20)
    }
    
    var outerCornerRadius: Double {
        (innerCornerRadius + thumbnailPadding).rounded(.up)
    }
    
    var allComponentsDisplayed: Bool {
        showDuration &&
        showChannelIcon &&
        showChannelName &&
        showChannelCount &&
        showViewCount &&
        showPublishDate &&
        showProgress
    }
}

private extension ThumbnailMakerViewModel {
    func extractVideoId(from urlStr: String) throws -> String? {
        guard let valideURL = checkIfURLIsValid(urlStr: urlStr) else { throw YMViewModelError.notAYoutubeURL }
        guard let comp = URLComponents(string: valideURL) else { return nil }
        guard let host = comp.host else { throw YMViewModelError.missingHost}
        guard !comp.path.starts(with: "/@") else { throw YMViewModelError.foundYouTubeChannelCustomUrl }
        
        if host == "youtu.be" {
            return comp.path.replacingOccurrences(of: "/", with: "")
        } else if host.contains("youtube.com") {
            if comp.path == "/watch", let videoId = comp.queryItems?.first(where: { $0.name == "v"})?.value {
                return videoId
            } else if comp.path.starts(with: "/shorts/") {
                return comp.path.replacingOccurrences(of: "/shorts/", with: "")
            }
            else {
                throw YMViewModelError.missingVideoId
            }
        } else {
            throw YMViewModelError.notAYoutubeVideoURL
        }
    }
    
    func extractChannelCustomUrl(from urlStr: String) throws -> String? {
        guard let valideURL = checkIfURLIsValid(urlStr: urlStr) else { throw YMViewModelError.notAYoutubeURL }
        guard let comp = URLComponents(string: valideURL) else { return nil }
        guard comp.path.starts(with: "/@") else { throw YMViewModelError.notAYoutubeChannelURL }
        return comp.path.replacingOccurrences(of: "/", with: "")
    }
}

private extension ThumbnailMakerViewModel {
    func observeUbiquitousKeyValueStore() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ubiquitousKeyValueStoreDidChange(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
    }
    
    @objc
    func ubiquitousKeyValueStoreDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else { return }
        
        guard reasonForChange != NSUbiquitousKeyValueStoreQuotaViolationChange else { return }
        
        guard let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
        DispatchQueue.main.async {
            if keys.contains(NSUbiquitousKeyValueStore.videoURlStrKey), NSUbiquitousKeyValueStore.default.videoURlStr.isNotEmpty {
                withAnimation {
                    self.videoURlStr = NSUbiquitousKeyValueStore.default.videoURlStr
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.showDurationKey) {
                withAnimation {
                    self.showDuration = NSUbiquitousKeyValueStore.default.showDuration
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.showChannelIconKey) {
                withAnimation {
                    self.showChannelIcon = NSUbiquitousKeyValueStore.default.showChannelIcon
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.showChannelNameKey) {
                withAnimation {
                    self.showChannelName = NSUbiquitousKeyValueStore.default.showChannelName
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.showChannelCountKey) {
                withAnimation {
                    self.showChannelCount = NSUbiquitousKeyValueStore.default.showChannelCount
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.showViewCountKey) {
                withAnimation {
                    self.showViewCount = NSUbiquitousKeyValueStore.default.showViewCount
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.showPublishDateKey) {
                withAnimation {
                    self.showPublishDate = NSUbiquitousKeyValueStore.default.showPublishDate
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.showProgressKey) {
                withAnimation {
                    self.showProgress = NSUbiquitousKeyValueStore.default.showProgress
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.lastProgressKey) {
                withAnimation {
                    self.lastProgress = NSUbiquitousKeyValueStore.default.lastProgress
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.isDarkThemeKey) {
                withAnimation {
                    self.isDarkTheme = NSUbiquitousKeyValueStore.default.isDarkTheme
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.thumbnailCornerRadiusKey) {
                withAnimation {
                    self.thumbnailCornerRadius = NSUbiquitousKeyValueStore.default.thumbnailCornerRadius
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.thumbnailPaddingKey) {
                withAnimation {
                    self.thumbnailPadding = NSUbiquitousKeyValueStore.default.thumbnailPadding
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.exportScaleKey) {
                withAnimation {
                    self.exportSize = NSUbiquitousKeyValueStore.default.exportSize
                }
            }
            if keys.contains(NSUbiquitousKeyValueStore.applySavedSettingsOnSelectFromHistoryKey) {
                withAnimation {
                    self.applySavedSettingsOnSelectFromHistory = NSUbiquitousKeyValueStore.default.applySavedSettingsOnSelectFromHistory
                }
            }
        }
    }

    func udObservers() {
        $videoURlStr
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.videoURlStr = newValue
                if newValue != NSUbiquitousKeyValueStore.default.videoURlStr {
                    NSUbiquitousKeyValueStore.default.videoURlStr = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)
        
        $showDuration
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.showDuration = newValue
                if newValue != NSUbiquitousKeyValueStore.default.showDuration {
                    NSUbiquitousKeyValueStore.default.showDuration = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)
        
        $showChannelIcon
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.showChannelIcon = newValue
                if newValue != NSUbiquitousKeyValueStore.default.showChannelIcon {
                    NSUbiquitousKeyValueStore.default.showChannelIcon = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)
        
        $showChannelName
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.showChannelName = newValue
                if newValue != NSUbiquitousKeyValueStore.default.showChannelName {
                    NSUbiquitousKeyValueStore.default.showChannelName = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)     
        
        $showChannelCount
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.showChannelCount = newValue
                if newValue != NSUbiquitousKeyValueStore.default.showChannelCount {
                    NSUbiquitousKeyValueStore.default.showChannelCount = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)
        
        $showViewCount
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.showViewCount = newValue
                if newValue != NSUbiquitousKeyValueStore.default.showViewCount {
                    NSUbiquitousKeyValueStore.default.showViewCount = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)
        
        $showPublishDate
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.showPublishDate = newValue
                if newValue != NSUbiquitousKeyValueStore.default.showPublishDate {
                    NSUbiquitousKeyValueStore.default.showPublishDate = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)
        
        $showProgress
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.showProgress = newValue
                if newValue != NSUbiquitousKeyValueStore.default.showProgress {
                    NSUbiquitousKeyValueStore.default.showProgress = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)
        
        $lastProgress
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.lastProgress = newValue
                if newValue != NSUbiquitousKeyValueStore.default.lastProgress {
                    NSUbiquitousKeyValueStore.default.lastProgress = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)
        
        $isDarkTheme
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.isDarkTheme = newValue
                if newValue != NSUbiquitousKeyValueStore.default.isDarkTheme {
                    NSUbiquitousKeyValueStore.default.isDarkTheme = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)
        
        $thumbnailCornerRadius
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.thumbnailCornerRadius = newValue
                if newValue != NSUbiquitousKeyValueStore.default.thumbnailCornerRadius {
                    NSUbiquitousKeyValueStore.default.thumbnailCornerRadius = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)  
        
        $thumbnailPadding
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.thumbnailPadding = newValue
                if newValue != NSUbiquitousKeyValueStore.default.thumbnailPadding {
                    NSUbiquitousKeyValueStore.default.thumbnailPadding = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)
        
        $exportSize
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.exportSize = newValue
                if newValue != NSUbiquitousKeyValueStore.default.exportSize {
                    NSUbiquitousKeyValueStore.default.exportSize = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)  
        
        $applySavedSettingsOnSelectFromHistory
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] newValue in
                UserDefaults.appGroup.applySavedSettingsOnSelectFromHistory = newValue
                if newValue != NSUbiquitousKeyValueStore.default.applySavedSettingsOnSelectFromHistory {
                    NSUbiquitousKeyValueStore.default.applySavedSettingsOnSelectFromHistory = newValue
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
                _ = try? PreviousURL.updateIfExist(videoId: self?.videoId)
            }
            .store(in: &cancellables)
    }
}
