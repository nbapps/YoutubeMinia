//
//  YTDecodable.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import Foundation

struct YTDecodable: Codable {
    let items: [YItem]
    let kind, etag: String
    let pageInfo: PageInfo
}

// MARK: - Item
struct YItem: Codable {
    let etag, kind, id: String
    let snippet: Snippet?
    let contentDetails: ContentDetails?
    let statistics: Statistics?
}

// MARK: - Snippet
struct Snippet: Codable {
    let title, description, channelId: String?
    let publishedAt: String
    let customUrl: String?
    let tags: [String]?
    let liveBroadcastContent, defaultLanguage, defaultAudioLanguage: String?
    let channelTitle: String?
    let thumbnails: Thumbnails?
    let localized: Localized?
    let categoryId: String?
}

// MARK: - Localized
struct Localized: Codable {
    let title, description: String?
}

// MARK: - Thumbnails
struct Thumbnails: Codable {
    let standard, medium, `default`, high, maxres: ThumbnailsURL?
}

// MARK: - Default
struct ThumbnailsURL: Codable {
    let url: String
    let width, height: Int
}

// MARK: - PageInfo
struct PageInfo: Codable {
    let resultsPerPage, totalResults: Int
}

struct ContentDetails: Codable {
    let duration: String
}

struct Statistics: Codable {
    /// Video or channel stats
    let viewCount: String?
    /// Video stats
    let likeCount: String?
    /// Channel stat
    let videoCount: String?
    /// Channel stat
    let subscriberCount: String?
    /// Video stat
    let favoriteCount: String?
    /// Content stat
    let commentCount: String?
}
