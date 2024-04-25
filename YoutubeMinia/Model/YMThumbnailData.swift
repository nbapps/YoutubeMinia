//
//  YMThumbnailData.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation
import SwiftData
import SwiftUI

struct YMThumbnailData {
    let videoURL: URL
    let videoThumbnailUrl: URL
    let channelThumbnailUrl: URL
    
    let videoTitle: String
    let channelTitle: String
    let viewCount: String
    let channelCount: String
    let videoDuration: String
    let publicationDate: Date
}

extension YMThumbnailData {
    static let moc: YMThumbnailData =
    YMThumbnailData(
        videoURL: URL(string: "https://www.youtube.com/watch?v=f7_CHu0ADhM")!,
        videoThumbnailUrl: URL(string: "https://i.ytimg.com/vi/f7_CHu0ADhM/maxresdefault.jpg")!,
        channelThumbnailUrl: URL(string: "https://yt3.ggpht.com/ytc/AIdro_ladyg5fV6ymBjPWBVtxYT06g8wSVa4-wnvez7kd9T-Ums=s240-c-k-c0x00ffffff-no-rj")!,
//        videoThumbnail: Image("videoThumbnail"),
//        channelThumbnail: Image("channelThumbail"),
        videoTitle: "Quel abonné codera la meilleure solution ?",
        channelTitle: "Benjamin Code",
        viewCount: "19740",
        channelCount: "131000",
        videoDuration: "16:31",
        publicationDate: Date(timeIntervalSince1970: 1643897325)
    )
}
