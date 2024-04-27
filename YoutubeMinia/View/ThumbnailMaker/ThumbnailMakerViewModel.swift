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
    case notAYoutubeVideoURL
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
    static let shared = ThumbnailMakerViewModel(fetchOnLaunch: true)
    static let preview = ThumbnailMakerViewModel(fetchOnLaunch: false)
    
    @Published var lastVideoURlStr: String?
    @Published var videoId: String?
    @Published var videoURlStr: String = UserDefaults.standard.videoURlStr
    @Published var showDuration: Bool = UserDefaults.standard.showDuration
    @Published var showChannelIcon: Bool = UserDefaults.standard.showChannelIcon
    @Published var showChannelName: Bool = UserDefaults.standard.showChannelName
    @Published var showChannelCount: Bool = UserDefaults.standard.showChannelCount
    @Published var showViewCount: Bool = UserDefaults.standard.showViewCount
    @Published var showPublishDate: Bool = UserDefaults.standard.showPublishDate
    @Published var showProgress: Bool = UserDefaults.standard.showProgress
    @Published var lastProgress: Double = UserDefaults.standard.lastProgress
    @Published var isDarkTheme: Bool = UserDefaults.standard.isDarkTheme
    @Published var thumbnailCornerRadius: Double = UserDefaults.standard.thumbnailCornerRadius
    @Published var thumbnailPadding: Double = UserDefaults.standard.thumbnailPadding
    
    @Published var applySavedSettingsOnSelectFromHistory: Bool = UserDefaults.standard.applySavedSettingsOnSelectFromHistory
    
    @Published var exportSize: ExportScale = UserDefaults.standard.exportSize
    
    @Published var ymThumbnailData: YMThumbnailData?
    @Published var videoThumbnail: Image?
    @Published var channelThumbnail: Image?
    
    @Published var isFetching = false
    @Published var exportAfterOnDrop = false
    
    @Published var selectedTab = Tabs.maker
    
    private let referenceWidth: CGFloat = 350
    
    var onExportSuccess: (() -> Void)?
    var isValidURL = false
    
    init(fetchOnLaunch: Bool) {
        udObservers()
        
        if fetchOnLaunch {
            if videoURlStr.isNotEmpty {
                Task { @MainActor in
                    try await fetch()
                }
            }
        }
        
        if ProcessInfo.runForPreview && !fetchOnLaunch {
            ymThumbnailData = .moc
            Task { @MainActor in
                try? await fetchThumbnails(videoThumbnailUrl: ymThumbnailData!.videoThumbnailUrl, channelThumbnailUrl: ymThumbnailData!.channelThumbnailUrl)
            }
        }
        
        $videoURlStr
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .compactMap { $0.isNotEmpty ? $0 : nil }
            .compactMap { [weak self] url in self?.checkIfURLIsValid(urlStr: url) }
            .sink { [weak self] newValue in
                guard let self else { return }
                Task { @MainActor in
                    try await self.fetch()
                }
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
            
            guard let thumbnailData = ymThumbnailData else { return }
            let rendered = ThumbnailView(thumbnailData: thumbnailData)
                .environmentObject(self)
                .getScaledImage(scale: exportSize.scale)

            copy(rendered.appImage)
        }
    }
    
    func copyPreviousThumbnailIfExisting() {
        Task { @MainActor in
            guard let thumbnailData = ymThumbnailData else { return }
            let rendered = ThumbnailView(thumbnailData: thumbnailData)
                .environmentObject(self)
                .getScaledImage(scale: exportSize.scale)
            
            copy(rendered.appImage)
        }
    }
    
    @MainActor
    func fetch() async throws {
        defer { isFetching = false }
        guard videoURlStr.isNotEmpty else { return }
        guard let videoURlStr = checkIfURLIsValid(urlStr: videoURlStr) else { return }
        
        guard lastVideoURlStr != videoURlStr else { return }
        
        guard let videoId = try extractVideoId(from: videoURlStr),
              let ytVideoUrl = Config.videoURL(for: videoId)
        else { return }
        
        ymThumbnailData = nil
        isFetching = true
        
        self.videoId = videoId
        self.lastVideoURlStr = videoURlStr
        
        print("start fetch")
        let videoReponse: YTDecodable = try await networkService.fetch(from: ytVideoUrl)
        guard let videoItem = videoReponse.items.first,
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
              let viewCount = videoStatistics.viewCount,
              let channelCount = channelStatistics.subscriberCount,
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
            viewCount: viewCount,
            channelCount: channelCount,
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
        print("fetch done")
    }
    
    @MainActor
    func fetchThumbnails(videoThumbnailUrl: URL, channelThumbnailUrl: URL) async throws {
        let videoThumbnailData: Data = try await networkService.fetch(url: videoThumbnailUrl)
        if let img = AppImage(data: videoThumbnailData) {
            self.videoThumbnail = Image(appImage: img)
        }
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
        let rendered = ThumbnailView(thumbnailData: thumbnailData)
            .environmentObject(self)
            .background(Color.clear)
            .getScaledImage(scale: exportSize.scale)

        // Mandatory to convert to png and re convert to image for keep transparency...
        guard let image = rendered.appImage, let data = image.pngData(), let final = UIImage(data: data) else {
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
        let rendered = ThumbnailView(thumbnailData: thumbnailData)
            .environmentObject(self)
            .getScaledImage(scale: exportSize.scale)
        
        try exportThumbnail(
            image: rendered.appImage,
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
    
    var bottomPadding: Double {
        mapValue(thumbnailPadding, fromRange: 8...20, toRange: 8...16)
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
        guard let valideURL = checkIfURLIsValid(urlStr: urlStr) else { throw YMViewModelError.notAYoutubeVideoURL }
        guard let comp = URLComponents(string: valideURL) else { return nil }
        guard let host = comp.host else { throw YMViewModelError.missingHost}
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
}

private extension ThumbnailMakerViewModel {
    func udObservers() {
        $videoURlStr
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.videoURlStr = newValue
            }
            .store(in: &cancellables)
        
        $showDuration
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.showDuration = newValue
            }
            .store(in: &cancellables)
        
        $showChannelIcon
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.showChannelIcon = newValue
            }
            .store(in: &cancellables)
        
        $showChannelName
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.showChannelName = newValue
            }
            .store(in: &cancellables)     
        
        $showChannelCount
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.showChannelCount = newValue
            }
            .store(in: &cancellables)
        
        $showViewCount
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.showViewCount = newValue
            }
            .store(in: &cancellables)
        
        $showPublishDate
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.showPublishDate = newValue
            }
            .store(in: &cancellables)
        
        $showProgress
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.showProgress = newValue
            }
            .store(in: &cancellables)
        
        $lastProgress
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.lastProgress = newValue
            }
            .store(in: &cancellables)
        
        $isDarkTheme
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.isDarkTheme = newValue
            }
            .store(in: &cancellables)
        
        $thumbnailCornerRadius
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.thumbnailCornerRadius = newValue
            }
            .store(in: &cancellables)  
        
        $thumbnailPadding
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.thumbnailPadding = newValue
            }
            .store(in: &cancellables)
        
        $exportSize
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.exportSize = newValue
            }
            .store(in: &cancellables)  
        
        $applySavedSettingsOnSelectFromHistory
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.applySavedSettingsOnSelectFromHistory = newValue
            }
            .store(in: &cancellables)
    }
}
