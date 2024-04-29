//
//  AppImage+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 26/04/2024.
//

import SwiftUI

#if os(macOS)
typealias AppImage = NSImage
#else
typealias AppImage = UIImage
#endif

extension AppImage {
    func copyImage() {
#if os(macOS)
        let pb = Clipboard.general
        pb.clearContents()
        pb.writeObjects([self])
#else
        Clipboard.general.image = self
#endif
    }
}

extension Image {
    init(appImage: AppImage) {
#if os(macOS)
        self.init(nsImage: appImage)
#else
        self.init(uiImage: appImage)
#endif
    }
}
