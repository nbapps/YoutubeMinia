//
//  VideoDurationView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI

struct VideoDurationView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    let value: String
    let thumbnailWidth: CGFloat
    
    var body: some View {
        Button(action: toggle) {
            Text(verbatim: value)
                .font(.roboto(weight: .medium, size: viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 12)))
                .foregroundStyle( .white)
                .padding(
                    .horizontal,
                    viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 6)
                )
                .padding(
                    .vertical,
                    viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 4)
                )
                .background(
                    .black.opacity(0.5),
                    in: RoundedRectangle(
                        cornerRadius: viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 6)
                    )
                )
                .padding(viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 8))
        }
        .accessibilityLabel("!Video duration")
        .buttonStyle(.plain)
    }
    
    func toggle() {
        withAnimation {
            viewModel.showDuration.toggle()
        }
    }
}

#Preview {
    VideoDurationView(
        value: "10:10",
        thumbnailWidth: 350
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
