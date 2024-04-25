//
//  NetworkService.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation

final class NetworkService {
    var session = URLSession(configuration: .default)

    func fetch<T: Decodable>(url: URL) async throws -> T {
        let data: Data = try await fetch(url: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func fetch(url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
