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
}

extension FileManager {
    func saveImageToDownloads(image: SharableImage?, fileName: String, fileExt: String) throws {
        guard let image else { throw FileManagerError.noImage }
        let downloadsDirectory = urls(for: .downloadsDirectory, in: .userDomainMask).first!
        
        let fileName = fileName.formatFileName() + Date().ISO8601Format() + ".\(fileExt)"
        let fileURL = downloadsDirectory.appendingPathComponent(fileName)
        
        guard let imageData = image.tiffRepresentation else {
            print("Failed to get image data")
            return
        }
        print(fileURL)
        
        try imageData.write(to: fileURL)
    }
}
