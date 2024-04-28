//
//  ChannelSubCountView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI

struct ChannelSubCountView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel

    let value: String
    let thumbnailWidth: CGFloat
    
    var body: some View {
        Button(action: toggle) {
            Text(value.formatChannelCount())
                .font(.roboto(size: viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 12)))
                .foregroundStyle(.gray)
        }
        .accessibilityLabel("!Channel subscribers")
        .buttonStyle(.plain)
    }
    
    func toggle() {
        withAnimation {
            viewModel.showChannelCount.toggle()
        }
    }
}

#Preview {
    ChannelSubCountView(    
        value: "131000",
        thumbnailWidth: 350
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
