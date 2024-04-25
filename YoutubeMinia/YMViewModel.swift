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
    case notAYoutubeURL
    case missingVideoId
    
    case missingResponse
}

final class YMViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService()
    
    static let shared = YMViewModel()
    
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
    
    @Published var ytVideoInfos: YTDecodable?
    @Published var ytChannelInfos: YTDecodable?
    
    @Published var ymThumbnailData: YMThumbnailData? = .moc
    @Published var videoThumbnail: Image?
    @Published var channelThumbnail: Image?
    
    @Published var isFetching = false
    
    init() {
        udObservers()
        
        $ymThumbnailData
            .compactMap { $0 }
            .sink { [weak self] data in
                guard let self else { return }
                Task { @MainActor in
                    await self.processImages(data: data)
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func processImages(data: YMThumbnailData) async {
        Task(priority: .userInitiated) { @MainActor in
            do {
                let video: Data = try await networkService.fetch(url: data.videoThumbnailUrl)
                
                if let img = NSImage(data: video) {
                    self.videoThumbnail = Image(nsImage: img)
                }
                print("video done")
            } catch {
                print(error)
            }
        }
        Task(priority: .userInitiated) { @MainActor in
            do {
                let channel: Data = try await networkService.fetch(url: data.channelThumbnailUrl)
                
                if let img = NSImage(data: channel) {
                    self.channelThumbnail = Image(nsImage: img)
                }
                print("channel done")
            } catch {
                print(error)
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
        
        isFetching = true
        
        let videoReponse: YTDecodable = try await networkService.fetch(url: ytVideoUrl)
        guard let videoItem = videoReponse.items.first,
              let videoSnippet = videoItem.snippet,
              let videoStatistics = videoItem.statistics,
              let thumbnails = videoSnippet.thumbnails,
              let videoThumbnails = thumbnails.maxres?.url,
              let channelId = videoSnippet.channelId
        else { throw YMViewModelError.missingResponse }
        
            let ytChannelUrl = Config.channelURL(for: channelId)
            let channelResponse: YTDecodable = try await networkService.fetch(url: ytVideoUrl)
        
        guard let channelItem = channelResponse.items.first,
              let channelSnippet = channelItem.snippet,
              let channelStatistics = channelItem.statistics,
              let channelThumbnails = channelSnippet.thumbnails?.medium?.url,
              let channelThumbnailUrl = URL(string: channelThumbnails)
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
        
        YMThumbnailData(
            videoURL: ytVideoUrl,
            videoThumbnailUrl: videoThumbnailUrl,
            channelThumbnailUrl: channelThumbnailUrl,
            videoTitle: videoTitle,
            channelTitle: channelTitle,
            viewCount: viewCount,
            channelCount: channelCount,
            videoDuration: <#T##String#>,
            publicationDate: publicationDate
        )
        
//        do {
//            let videoData = try Bundle.main.loadJSONData(from: "devVideo.json")
//            let videoDecoded = try JSONDecoder().decode(YTDecodable.self, from: videoData)
//            ytVideoInfos = videoDecoded
//            //            print("https://www.googleapis.com/youtube/v3/channels?part=snippet&id=\(videoDecoded.items.first!.snippet.channelId)&key=\(viewModel.apiKey)")
//            
//            let channelData = try Bundle.main.loadJSONData(from: "devChannel.json")
//            let channelDecoded = try JSONDecoder().decode(YTDecodable.self, from: channelData)
//            ytChannelInfos = channelDecoded
//            //            print(channelDecoded)
//        } catch {
//            print(error)
//        }
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
        } else if host.contains("youtube.com"), comp.path == "/watch" {
            if let videoId = comp.queryItems?.first(where: { $0.name == "v"})?.value {
                return videoId
            } else {
                throw YMViewModelError.missingVideoId
            }
        } else {
            throw YMViewModelError.notAYoutubeURL
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
