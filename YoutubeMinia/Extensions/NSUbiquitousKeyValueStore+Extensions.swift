//
//  NSUbiquitousKeyValueStore+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import Foundation

extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: Config.appGroup)!
    
    var videoURlStr: String {
        get { string(forKey: NSUbiquitousKeyValueStore.videoURlStrKey) ?? "" }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.videoURlStrKey) }
    }
    
    var showDuration: Bool {
        get { bool(forKey: NSUbiquitousKeyValueStore.showDurationKey) }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.showDurationKey) }
    }
    
    var showChannelIcon: Bool {
        get { bool(forKey: NSUbiquitousKeyValueStore.showChannelIconKey) }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.showChannelIconKey) }
    }
    
    var showChannelName: Bool {
        get { bool(forKey: NSUbiquitousKeyValueStore.showChannelNameKey) }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.showChannelNameKey) }
    }
    
    var showChannelCount: Bool {
        get { bool(forKey: NSUbiquitousKeyValueStore.showChannelCountKey) }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.showChannelCountKey) }
    }
    
    var showViewCount: Bool {
        get { bool(forKey: NSUbiquitousKeyValueStore.showViewCountKey) }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.showViewCountKey) }
    }
    
    var showPublishDate: Bool {
        get { bool(forKey: NSUbiquitousKeyValueStore.showPublishDateKey) }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.showPublishDateKey) }
    }
    
    var showProgress: Bool {
        get { bool(forKey: NSUbiquitousKeyValueStore.showProgressKey) }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.showProgressKey) }
    }
    
    var lastProgress: Double {
        get { double(forKey: NSUbiquitousKeyValueStore.lastProgressKey) }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.lastProgressKey) }
    }
    
    var isDarkTheme: Bool {
        get { bool(forKey: NSUbiquitousKeyValueStore.isDarkThemeKey) }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.isDarkThemeKey) }
    }
    
    
    var thumbnailCornerRadius: Double {
        get { double(forKey: NSUbiquitousKeyValueStore.thumbnailCornerRadiusKey) }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.thumbnailCornerRadiusKey) }
    }
    
    var thumbnailPadding: Double {
        get {
            let val = double(forKey: NSUbiquitousKeyValueStore.thumbnailPaddingKey)
            return val < 8 ? 8: val
        }
        set {
            set(
                newValue >= 8 ? newValue : 8,
                forKey: NSUbiquitousKeyValueStore.thumbnailPaddingKey
            )
        }
    }
    
    var exportSize: ExportScale {
        get {
            guard let val = string(forKey: NSUbiquitousKeyValueStore.exportScaleKey) else { return .x2}
            return ExportScale(rawValue: val) ?? .x2
        }
        set { set(newValue.rawValue, forKey: NSUbiquitousKeyValueStore.exportScaleKey) }
    }
    
    var applySavedSettingsOnSelectFromHistory: Bool {
        get { bool(forKey: NSUbiquitousKeyValueStore.applySavedSettingsOnSelectFromHistoryKey) }
        set { set(newValue, forKey: NSUbiquitousKeyValueStore.applySavedSettingsOnSelectFromHistoryKey) }
    }
}

extension NSUbiquitousKeyValueStore {
    static let videoURlStrKey = "lastURlStrKey"
    var videoURlStr: String {
        get { string(forKey: Self.videoURlStrKey) ?? "" }
        set { set(newValue, forKey: Self.videoURlStrKey) }
    }
    
    static let showDurationKey = "showDurationKey"
    var showDuration: Bool {
        get { bool(forKey: Self.showDurationKey) }
        set { set(newValue, forKey: Self.showDurationKey) }
    }
    
    static let showChannelIconKey = "showChannelIconKey"
    var showChannelIcon: Bool {
        get { bool(forKey: Self.showChannelIconKey) }
        set { set(newValue, forKey: Self.showChannelIconKey) }
    }
    
    static let showChannelNameKey = "showChannelNameKey"
    var showChannelName: Bool {
        get { bool(forKey: Self.showChannelNameKey) }
        set { set(newValue, forKey: Self.showChannelNameKey) }
    }
    
    static let showChannelCountKey = "showChannelCountKey"
    var showChannelCount: Bool {
        get { bool(forKey: Self.showChannelCountKey) }
        set { set(newValue, forKey: Self.showChannelCountKey) }
    }
    
    static let showViewCountKey = "showViewCountKey"
    var showViewCount: Bool {
        get { bool(forKey: Self.showViewCountKey) }
        set { set(newValue, forKey: Self.showViewCountKey) }
    }
    
    static let showPublishDateKey = "showPublishDateKey"
    var showPublishDate: Bool {
        get { bool(forKey: Self.showPublishDateKey) }
        set { set(newValue, forKey: Self.showPublishDateKey) }
    }
    
    
    static let showProgressKey = "showProgressKey"
    var showProgress: Bool {
        get { bool(forKey: Self.showProgressKey) }
        set { set(newValue, forKey: Self.showProgressKey) }
    }
    static let lastProgressKey = "lastProgressKey"
    var lastProgress: Double {
        get { double(forKey: Self.lastProgressKey) }
        set { set(newValue, forKey: Self.lastProgressKey) }
    }
    
    static let isDarkThemeKey = "isDarkThemeKey"
    var isDarkTheme: Bool {
        get { bool(forKey: Self.isDarkThemeKey) }
        set { set(newValue, forKey: Self.isDarkThemeKey) }
    }
    
    static let thumbnailCornerRadiusKey = "thumbnailCornerRadiusKey"
    var thumbnailCornerRadius: Double {
        get { double(forKey: Self.thumbnailCornerRadiusKey) }
        set { set(newValue, forKey: Self.thumbnailCornerRadiusKey) }
    }
    
    static let thumbnailPaddingKey = "thumbnailPaddingKey"
    var thumbnailPadding: Double {
        get {
            let val = double(forKey: Self.thumbnailPaddingKey)
            return val < 8 ? 8: val
        }
        set {
            set(
                newValue >= 8 ? newValue : 8,
                forKey: Self.thumbnailPaddingKey
            )
        }
    }
    
    static let exportScaleKey = "exportScaleKey"
    var exportSize: ExportScale {
        get {
            guard let val = string(forKey: Self.exportScaleKey) else { return .x2}
            return ExportScale(rawValue: val) ?? .x2
        }
        set { set(newValue.rawValue, forKey: Self.exportScaleKey) }
    }
    
    static let applySavedSettingsOnSelectFromHistoryKey = "applySavedSettingsOnSelectFromHistoryKey"
    var applySavedSettingsOnSelectFromHistory: Bool {
        get { bool(forKey: Self.applySavedSettingsOnSelectFromHistoryKey) }
        set { set(newValue, forKey: Self.applySavedSettingsOnSelectFromHistoryKey) }
    }
}
