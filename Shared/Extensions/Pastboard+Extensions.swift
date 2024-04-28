//
//  Pastboard+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 26/04/2024.
//

import SwiftUI

#if os(macOS)
typealias Clipboard = NSPasteboard
#else
typealias Clipboard = UIPasteboard
#endif

extension Clipboard {
    func getString() -> String? {
#if os(macOS)
        string(forType: .string)
#else
        string
#endif
    }
    
    func copyImage(_ image: AppImage) {
#if os(macOS)
        clearContents()
        writeObjects([image])
#else
        self.image = image
#endif
    }
}

