//
//  ThumbnailViewOrEmpty.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 28/04/2024.
//

import SwiftUI

struct ThumbnailViewOrEmpty: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    init(width: CGFloat) {
        self.width = min(width, 700)
    }
    
    private let width: CGFloat
    
    var body: some View {
        Group {
            if let thumbnailData = viewModel.ymThumbnailData {
                ThumbnailView(thumbnailData: thumbnailData, width: width)
                    .draggableIfAllow(
                        image: viewModel.renderThumbnail()
                    )
                
            } else {
                EmptyThumbnailView(width: width)
            }
        }
        .frame(maxWidth: width)
    }
}

#Preview {
    ThumbnailViewOrEmpty(
        width: 300
    )
//    .scaledToFit()
//    .frame(width: 300)
    .environmentObject(ThumbnailMakerViewModel.preview)
}
