//
//  SharableFile.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI

struct SharableFile: Codable {
    var videoURlStr: String = NSUbiquitousKeyValueStore.default.videoURlStr
    var videoTitle: String
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

extension SharableFile: Transferable {
    
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .ymSharableFileExportType)
            .suggestedFileName { "\($0.videoTitle.formatFileName())_" + Date().formatted(.iso8601) }
    }
}

import UniformTypeIdentifiers

public extension UTType {
    static var ymSharableFileExportType = UTType(exportedAs: "com.nbapps.youtubeMinia.fileIentifier")
}
