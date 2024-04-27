//
//  VideoProgressView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI

struct VideoProgressView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    let value: Double
    let thumbnailWidth: CGFloat
    
    var body: some View {
        Button(action: toggle) {
            RoundedRectangle(
                cornerRadius: viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 8)
            )
            .frame(
                width: thumbnailWidth * viewModel.lastProgress,
                height: viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 5),
                alignment: .leading
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.red)
            .padding(
                .bottom,
                viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 1)
            )
        }
        .accessibilityLabel("!Video progress bar")
        .buttonStyle(.plain)
    }
    
    func toggle() {
        withAnimation {
            viewModel.showProgress.toggle()
        }
    }
}

#Preview {
    VideoProgressView(
        value: 0.5,
        thumbnailWidth: 350
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
