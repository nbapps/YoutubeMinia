//
//  SharableFile.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI

struct SharableFile: Codable {
    var videoURlStr: String = UserDefaults.standard.videoURlStr
    var videoTitle: String
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

extension SharableFile: Transferable {
    
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .ymSharableFileExportType)
            .suggestedFileName { "\($0.videoTitle)_" + Date().formatted(.iso8601) }
    }
}

import UniformTypeIdentifiers

public extension UTType {
    static var ymSharableFileExportType = UTType(exportedAs: "com.nbapps.youtubeMinia.fileIentifier")
}
