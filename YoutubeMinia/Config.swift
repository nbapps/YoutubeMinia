//
//  Config.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import Foundation

struct Config {
    static let ytBaseURLStr = "https://www.googleapis.com/youtube/v3/"
    static let apiKey = Config.getValue(for: .youtubeApiKey)!
    
    static func videoURL(for videoId: String) -> URL? {
        guard var urlComponents = URLComponents(string: ytBaseURLStr + "videos") else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "part", value: "snippet,statistics,contentDetails"),
            URLQueryItem(name: "id", value: videoId),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        return urlComponents.url?.absoluteURL
    }
    
    static func channelURL(for channelId: String) -> URL? {
        guard var urlComponents = URLComponents(string: ytBaseURLStr + "channels") else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "part", value: "snippet,statistics"),
            URLQueryItem(name: "id", value: channelId),
            URLQueryItem(name: "key", value: apiKey)
        ]

        return urlComponents.url?.absoluteURL
    }
    
    enum Key: String {
        case youtubeApiKey = "YT_API_KEY"
    }
    
    static func getValue(for key: Key) -> String? {
         Bundle.main.object(forInfoDictionaryKey: key.rawValue) as? String
    }
}
