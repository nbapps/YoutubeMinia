//
//  NetworkService.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation

final class NetworkService {
    var session = URLSession(configuration: .default)
    
    func tt() async throws {
        let data: Data = try await fetch(url: URL(string: "https://yt3.ggpht.com/ytc/AIdro_ladyg5fV6ymBjPWBVtxYT06g8wSVa4-wnvez7kd9T-Ums=s88-c-k-c0x00ffffff-no-rj")!)
        //        Image(nsImage: NSImage(data: data))
    }
    
    func fetch<T: Decodable>(url: URL) async throws -> T {
        let data: Data = try await fetch(url: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func fetch(url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
/*
 func fetchVideoInfo(videoId: String, apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
 let urlString = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=\(videoId)&key=\(apiKey)"
 let urlString11 = "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=\(123)&key=\(apiKey)"
 
 guard let url = URL(string: urlString) else {
 completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
 return
 }
 
 let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
 if let error = error {
 completion(.failure(error))
 return
 }
 
 guard let data = data else {
 completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
 return
 }
 
 do {
 let decoded = try JSONDecoder().decode(YTDecodable.self, from: data)
 print(decoded)
 let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
 
 
 let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
 let prettyPrintedString = String(data: data!, encoding: .utf8)
 
 //                print(prettyPrintedString!)
 
 if let items = json?["items"] as? [[String: Any]], let snippet = items.first?["snippet"] as? [String: Any], let thumbnails = snippet["thumbnails"] as? [String: Any], let defaultThumbnail = thumbnails["default"] as? [String: Any], let thumbnailURL = defaultThumbnail["url"] as? String {
 completion(.success(thumbnailURL))
 } else {
 completion(.failure(NSError(domain: "Invalid JSON format", code: 0, userInfo: nil)))
 }
 } catch {
 completion(.failure(error))
 }
 }
 
 task.resume()
 }
 */
