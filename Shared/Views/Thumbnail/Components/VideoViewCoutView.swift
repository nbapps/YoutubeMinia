//
//  VideoViewCoutView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI

struct VideoViewCountView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    let value: String
    let thumbnailWidth: CGFloat
    
    var body: some View {
        Button(action: toggle) {
            Text(verbatim: value.formatViewCount())
                .font(.roboto(size: viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 12)))
                .foregroundStyle(.gray)
        }
        .accessibilityLabel("!Total views")
        .buttonStyle(.plain)
    }
    
    func toggle() {
        withAnimation {
            viewModel.showViewCount.toggle()
        }
    }
}

#Preview {
    VideoViewCountView(
        value: "210124",
        thumbnailWidth: 350
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
