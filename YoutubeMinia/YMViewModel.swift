//
//  YMViewModel.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation
import Combine
import SwiftUI

enum YMViewModelError: Error {
    case missingHost
    case notAYoutubeVideoURL
    case missingVideoId
    case missingChannelId
    
    case missingResponse
}

final class YMViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService()
    
    static let shared = YMViewModel(fetchOnLaunch: true)
    static let preview = YMViewModel(fetchOnLaunch: false)
    
    @Published var lastVideoURlStr: String = UserDefaults.standard.lastVideoURlStr
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
    
    @Published var ymThumbnailData: YMThumbnailData?
    @Published var videoThumbnail: Image?
    @Published var channelThumbnail: Image?
    
    @Published var isFetching = false
    
    init(fetchOnLaunch: Bool) {
        udObservers()
        
        if fetchOnLaunch {
            if lastVideoURlStr.isNotEmpty {
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
    }

    @MainActor
    func fetch() async throws {
        defer { isFetching = false }
        guard lastVideoURlStr.isNotEmpty else { return }
        guard let videoId = try extractVideoId(from: lastVideoURlStr),
              let ytVideoUrl = Config.videoURL(for: videoId)
        else { return }
        
        ymThumbnailData = nil
        isFetching = true
        
        let videoReponse: YTDecodable = try await networkService.fetch(url: ytVideoUrl)
        guard let videoItem = videoReponse.items.first,
              let videoSnippet = videoItem.snippet,
              let videoStatistics = videoItem.statistics,
              let thumbnails = videoSnippet.thumbnails,
              let videoThumbnails = thumbnails.maxres?.url,
              let channelId = videoSnippet.channelId
        else { throw YMViewModelError.missingResponse }
        
        guard let ytChannelUrl = Config.channelURL(for: channelId)else { throw YMViewModelError.missingChannelId }
        
            let channelResponse: YTDecodable = try await networkService.fetch(url: ytChannelUrl)
        
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
        
        self.ymThumbnailData = YMThumbnailData(
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
        
        try await fetchThumbnails(
            videoThumbnailUrl: videoThumbnailUrl,
            channelThumbnailUrl: channelThumbnailUrl
        )
    }
    
    @MainActor
    func fetchThumbnails(videoThumbnailUrl: URL, channelThumbnailUrl: URL) async throws {
        let videoThumbnailData: Data = try await networkService.fetch(url: videoThumbnailUrl)
        if let img = NSImage(data: videoThumbnailData) {
            self.videoThumbnail = Image(nsImage: img)
        }
        let channelThumbnailData: Data = try await networkService.fetch(url: channelThumbnailUrl)
        if let img = NSImage(data: channelThumbnailData) {
            self.channelThumbnail = Image(nsImage: img)
        }
    }
    
    @MainActor
    func copy(_ image: NSImage?) {
        guard let image else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([image])
    }
    
    func extractVideoId(from urlStr: String) throws -> String? {
        guard let comp = URLComponents(string: urlStr) else { return nil }
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
    
    func mapValue(_ value: Double, fromRange: ClosedRange<Double>, toRange: ClosedRange<Double>) -> Double {
        let fromMin = fromRange.lowerBound
        let fromMax = fromRange.upperBound
        let toMin = toRange.lowerBound
        let toMax = toRange.upperBound
        
        let result = (value - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin
        return result.rounded(.up)
    }
}

private extension YMViewModel {
    func udObservers() {
        $lastVideoURlStr
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .sink { newValue in
                UserDefaults.standard.lastVideoURlStr = newValue
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
    }
}
