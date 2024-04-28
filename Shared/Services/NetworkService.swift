//
//  NetworkService.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation

private let memoryCapacity = 500 * 1024 * 1024 // 500 MB
private let diskCapacity = 1 * 1024 * 1024 * 1024 // 1 GB

let cache = URLCache(
    memoryCapacity: memoryCapacity,
    diskCapacity: diskCapacity
)

enum NetworkServiceError: Error {
    case missingURL
}

final class NetworkService {
    
    let session: URLSession = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad
        sessionConfiguration.urlCache = cache
        return URLSession(configuration: sessionConfiguration)
    }()

    func fetch<T: Decodable>(from url: URL) async throws -> T {
        let data: Data = try await fetch(url: url)
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func fetch(url: URL?) async throws -> Data {
        guard let url else { throw NetworkServiceError.missingURL }
        let request = URLRequest(url: url)
        
        if let cachedData = cache.cachedResponse(for: request) {
            return cachedData.data
        }
        
        let (data, response) = try await session.data(for: request)
        let cachedData = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedData, for: request)
        
        return data
    }
}
