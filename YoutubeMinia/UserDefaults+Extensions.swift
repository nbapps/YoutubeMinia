//
//  UserDefaults+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import Foundation

extension UserDefaults {
    static let lastVideoURlStrKey = "lastURlStrKey"
    var lastVideoURlStr: String {
        get { string(forKey: Self.lastVideoURlStrKey) ?? "" }
        set { set(newValue, forKey: Self.lastVideoURlStrKey) }
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
}
