//
//  Bundle+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation

extension Bundle {
    var appVersion: String {
        guard let appVersion = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return "n/a"}
        return appVersion
    }
    
    var buildNumber: String {
        guard let buildNumber = object(forInfoDictionaryKey: "CFBundleVersion") as? String else { return "n/a"}
        return buildNumber
    }
    
    var appVersionAndBuild: String {
        "\(appVersion) - \(buildNumber)"
    }
    var appName: String {
        guard let appName = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String else { return "n/a" }
        return appName
    }
}


extension Bundle {
    func loadJSONData(from file: String) throws -> Data {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            throw JSONDataError.fileNotFound(file)
        }
        
        guard let data = try? Data(contentsOf: url) else {
            throw JSONDataError.failedToLoad(file)
        }
        
        return data
    }
    
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> T {
        
        let data = try loadJSONData(from: file)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            throw JSONDataError.keyNotFound(file: file, key: key.stringValue, context: context.debugDescription)
        } catch DecodingError.typeMismatch(let type, let context) {
            throw JSONDataError.typeMismatch(file: file, type: type, context: context.debugDescription)
        } catch DecodingError.valueNotFound(let type, let context) {
            throw JSONDataError.valueNotFound(file: file, type: type, context: context.debugDescription)
        } catch DecodingError.dataCorrupted(_) {
            throw JSONDataError.dataCorrupted(file: file)
        } catch {
            throw JSONDataError.error(file: file, error: error.localizedDescription)
        }
    }
}

public enum JSONDataError: Error {
    case fileNotFound(String)
    case failedToLoad(String)
    
    case keyNotFound(file: String, key: String, context: String)
    case typeMismatch(file: String, type: Any, context: String)
    case valueNotFound(file: String, type: Any, context: String)
    case dataCorrupted(file: String)
    case error(file: String, error: String)
}

extension JSONDataError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let file):
            "Failed to locate \(file) in bundle."
            
        case .failedToLoad(let file):
            
            "Failed to load \(file) from bundle."
        case .keyNotFound(let file, let key, let context):
            "Failed to decode \(file) from bundle due to missing key '\(key)' not found – \(context)"
            
        case .typeMismatch(let file, let type, let context):
            "Failed to decode \(file) from bundle due to type mismatch \(type) – \(context)"
            
        case .valueNotFound( let file, let type,let context):
            "Failed to decode \(file) from bundle due to missing \(type) value – \(context)"
            
        case .dataCorrupted(let file):
            "Failed to decode \(file) from bundle because it appears to be invalid JSON"
            
        case .error(let file, let error):
            "Failed to decode \(file) from bundle: \(error)"
        }
    }
}
