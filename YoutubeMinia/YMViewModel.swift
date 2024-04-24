//
//  YMViewModel.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation
import Combine

final class YMViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService()
    
    @Published var lastVideoURlStr: String = UserDefaults.standard.lastVideoURlStr
    @Published var showDuration: Bool = UserDefaults.standard.showDuration
    @Published var showChannelIcon: Bool = UserDefaults.standard.showChannelIcon
    @Published var showChannelName: Bool = UserDefaults.standard.showChannelName
    @Published var showViewCount: Bool = UserDefaults.standard.showViewCount
    @Published var showPublishDate: Bool = UserDefaults.standard.showPublishDate
    @Published var showProgress: Bool = UserDefaults.standard.showProgress
    @Published var lastProgress: Double = UserDefaults.standard.lastProgress
    @Published var isDarkTheme: Bool = UserDefaults.standard.isDarkTheme
    @Published var thumbnailCornerRadius: Double = UserDefaults.standard.thumbnailCornerRadius
    
    @Published var ytVideoInfos: YTDecodable?
    @Published var ytChannelInfos: YTDecodable?
    
    @Published var ymThumbnailData: YMThumbnailData? = .moc
    
    init() {
        udObservers()
        //        $ytChannelInfos
        //            .compactMap { $0 }
        //            .sink { [weak self] channel in
        //                channel.items.first!.snippet.thumbnails!.default!.url
        //                Task {
        //                    try? await networkService.fetch(url: <#T##URL#>)
        //                }
        //            }
        //            .store(in: &cancellables)
    }
    
    func udObservers() {
        $lastVideoURlStr
            .sink { newValue in
                UserDefaults.standard.lastVideoURlStr = newValue
            }
            .store(in: &cancellables)
        $showDuration
            .sink { newValue in
                UserDefaults.standard.showDuration = newValue
            }
            .store(in: &cancellables)
        $showChannelIcon
            .sink { newValue in
                UserDefaults.standard.showChannelIcon = newValue
            }
            .store(in: &cancellables)
        $showChannelName
            .sink { newValue in
                UserDefaults.standard.showChannelName = newValue
            }
            .store(in: &cancellables)
        $showViewCount
            .sink { newValue in
                UserDefaults.standard.showViewCount = newValue
            }
            .store(in: &cancellables)
        $showPublishDate
            .sink { newValue in
                UserDefaults.standard.showPublishDate = newValue
            }
            .store(in: &cancellables)
        $showProgress
            .sink { newValue in
                UserDefaults.standard.showProgress = newValue
            }
            .store(in: &cancellables)
        $lastProgress
            .sink { newValue in
                UserDefaults.standard.lastProgress = newValue
            }
            .store(in: &cancellables)
        $isDarkTheme
            .sink { newValue in
                UserDefaults.standard.isDarkTheme = newValue
            }
            .store(in: &cancellables)
        $thumbnailCornerRadius
            .sink { newValue in
                UserDefaults.standard.thumbnailCornerRadius = newValue
            }
            .store(in: &cancellables)
    }
}
