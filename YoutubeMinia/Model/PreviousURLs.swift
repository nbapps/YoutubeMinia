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
    
    var urlStr: String
    var videoId: String
    var title: String
    var thumbnailUrlStr: String?
    var timestamp: Date
    
    // TODO: save conf for recrate preview
    var videoURlStr: String = UserDefaults.standard.videoURlStr
    var showDuration: Bool = UserDefaults.standard.showDuration
    var showChannelIcon: Bool = UserDefaults.standard.showChannelIcon
    var showChannelName: Bool = UserDefaults.standard.showChannelName
    var showChannelCount: Bool = UserDefaults.standard.showChannelCount
    var showViewCount: Bool = UserDefaults.standard.showViewCount
    var showPublishDate: Bool = UserDefaults.standard.showPublishDate
    var showProgress: Bool = UserDefaults.standard.showProgress
    var lastProgress: Double = UserDefaults.standard.lastProgress
    var isDarkTheme: Bool = UserDefaults.standard.isDarkTheme
    var thumbnailCornerRadius: Double = UserDefaults.standard.thumbnailCornerRadius
    var thumbnailPadding: Double = UserDefaults.standard.thumbnailPadding
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
        
        if var existing {
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
