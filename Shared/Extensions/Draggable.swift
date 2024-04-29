//
//  Draggable.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI

extension View {
    func draggableIfAllow(image: AppImage?) -> some View {
        modifier(DraggableAllow(image: image))
    }
}

struct DraggableAllow: ViewModifier {
    let image: AppImage?
    
    func body(content: Content) -> some View {
        if let image {
            content
                .draggable(Image(appImage: image))
        } else {
            content
        }
    }
}
