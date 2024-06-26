//
//  View+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI

extension View {
    func thumbnailShadow(radius: CGFloat = 4) -> some View {
        self
            .shadow(color: .clear, radius: radius)
            .shadow(color: .black.opacity(0.2), radius: radius)
    }
    
    @MainActor
    func getScaledImage(scale: CGFloat) -> ImageRenderer<Self> {
        let rendered = ImageRenderer(content: self)
        rendered.scale = scale
        return rendered
    }
}

extension ImageRenderer {
    @MainActor
    var appImage: AppImage? {
#if os(macOS)
        nsImage
#else
        uiImage
#endif
    }
}
