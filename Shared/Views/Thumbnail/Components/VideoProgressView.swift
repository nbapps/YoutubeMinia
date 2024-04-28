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
        GeometryReader { proxy in
            Button(action: toggle) {
                ZStack {
                    Capsule()
                        .foregroundStyle(.black.opacity(0.1))
                        .frame(
                            alignment: .trailing
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Capsule()
                        .foregroundStyle(.red)
                        .frame(
                            width: (proxy.size.width * viewModel.lastProgress),
                            alignment: .leading
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(
                    .bottom,
                    viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 1)
                )
            }
            .accessibilityLabel("!Video progress bar")
            .buttonStyle(.plain)
        }
        .frame(height: viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 5))
        .fixedSize(horizontal: false, vertical: true)
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
