//
//  ChannelThumbnailView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI

struct ChannelThumbnailView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    let value: Image?
    let thumbnailWidth: CGFloat
    
    var body: some View {
        Button(action: toggle) {
            ZStack {
                if let value {
                    value
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .thumbnailShadow()
                } else {
                    ProgressView()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
            .frame(width: viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 40))
        }
        .accessibilityLabel("!Channel thumbnail")
        .buttonStyle(.plain)
    }
    
    func toggle() {
        withAnimation {
            viewModel.showChannelIcon.toggle()
        }
    }
}

#Preview {
    ChannelThumbnailView(
        value: Image(systemName: "plus"),
        thumbnailWidth: 350
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
