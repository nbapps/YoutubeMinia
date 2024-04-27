//
//  PreviousURLs.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 26/04/2024.
//

import Foundation
import SwiftData

@Model
final class PreviousURL {
    init(
        urlStr: String,
        videoId: String,
        title: String,
        thumbnailUrlStr: String?,
        timestamp: Date
    ) {
        self.urlStr = urlStr
        self.videoId = videoId
        self.title = title
        self.thumbnailUrlStr = thumbnailUrlStr
        self.timestamp = timestamp
    }
    
    var urlStr: String = ""
    var videoId: String = ""
    var title: String = ""
    var thumbnailUrlStr: String?
    var timestamp: Date = Date.now
    
    var videoURlStr: String = NSUbiquitousKeyValueStore.default.videoURlStr
    var showDuration: Bool = NSUbiquitousKeyValueStore.default.showDuration
    var showChannelIcon: Bool = NSUbiquitousKeyValueStore.default.showChannelIcon
    var showChannelName: Bool = NSUbiquitousKeyValueStore.default.showChannelName
    var showChannelCount: Bool = NSUbiquitousKeyValueStore.default.showChannelCount
    var showViewCount: Bool = NSUbiquitousKeyValueStore.default.showViewCount
    var showPublishDate: Bool = NSUbiquitousKeyValueStore.default.showPublishDate
    var showProgress: Bool = NSUbiquitousKeyValueStore.default.showProgress
    var lastProgress: Double = NSUbiquitousKeyValueStore.default.lastProgress
    var isDarkTheme: Bool = NSUbiquitousKeyValueStore.default.isDarkTheme
    var thumbnailCornerRadius: Double = NSUbiquitousKeyValueStore.default.thumbnailCornerRadius
    var thumbnailPadding: Double = NSUbiquitousKeyValueStore.default.thumbnailPadding
}

extension PreviousURL {
    static func getMocItem() throws -> PreviousURL {
        try PreviousURL.add(
            "https://www.youtube.com/watch?v=f7_CHu0ADhM&pp=ygUNYmVuamFtaW4gY29kZQ%3D%3D",
            videoId: "f7_CHu0ADhM",
            title: "Quel abonné codera la meilleure solution ?",
            thumbnailUrlStr: "https://i.ytimg.com/vi/f7_CHu0ADhM/default.jpg",
            timestamp: .now
        )
    }
}
extension PreviousURL {
    var thumbnailUrl: URL? {
        guard let thumbnailUrlStr else { return nil }
        return URL(string: thumbnailUrlStr)
    }
    
    static func existingEntry(for videoId: String) -> Predicate<PreviousURL> {
        return #Predicate<PreviousURL> { entry in
            entry.videoId == videoId
        }
    }
    
    @discardableResult
    static func add(
        _ videoURlStr: String,
        videoId: String,
        title: String,
        thumbnailUrlStr: String?,
        timestamp: Date = .now
    ) throws -> PreviousURL {
        let context = ModelContext(Database.container)
        
        var descriptor = FetchDescriptor<PreviousURL>(predicate: existingEntry(for: videoId))
        descriptor.fetchLimit = 1
        let existing = try context.fetch(descriptor).first
        
        if let existing {
            existing.timestamp = .now
            try context.save()
            return existing
        }
        
        let new = PreviousURL(
            urlStr: videoURlStr,
            videoId: videoId,
            title: title,
            thumbnailUrlStr: thumbnailUrlStr,
            timestamp: timestamp
        )
        
        context.insert(new)
        // Explicite save because sometime context is not auto saved by swift data..
        try context.save()
        
        return new
    }
}
