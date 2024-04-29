//
//  FileManager+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation

#if canImport(AppKit)
import AppKit
typealias SharableImage = NSImage
#elseif canImport(UIKit)
import UIKit
typealias SharableImage = UIImage
#endif

enum FileManagerError: Error {
    case noImage
    case cantGetData
}

extension FileManager {
    @discardableResult
    func saveImageToDownloads(image: SharableImage?, fileName: String, fileExt: String) throws -> URL {
        guard let image else { throw FileManagerError.noImage }
        let downloadsDirectory = urls(for: .downloadsDirectory, in: .userDomainMask).first!
        
        let fileName = fileName.formatFileName() + Date().ISO8601Format() + ".\(fileExt)"
        let fileURL = downloadsDirectory.appendingPathComponent(fileName)
        
#if os(macOS)
        guard let imageData = image.tiffRepresentation else {
            throw FileManagerError.cantGetData
        }
#else
        guard let imageData = image.pngData() else {
            throw FileManagerError.cantGetData
        }
#endif

        try imageData.write(to: fileURL)
        
        return fileURL
    }
}
