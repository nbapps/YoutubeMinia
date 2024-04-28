//
//  ThumbnailViewOrEmpty.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 28/04/2024.
//

import SwiftUI

struct ThumbnailViewOrEmpty: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    let width: CGFloat
    
    var body: some View {
        if let thumbnailData = viewModel.ymThumbnailData {
            ThumbnailView(thumbnailData: thumbnailData, width: width)
                .draggableIfAllow(
                    image: viewModel.renderThumbnail()
                )
            
        } else {
            EmptyThumbnailView(width: width)
        }
    }
}

#Preview {
    ThumbnailViewOrEmpty(
    width: 300
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
