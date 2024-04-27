//
//  ChannelTitleView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI

struct ChannelTitleView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    let value: String
    let thumbnailWidth: CGFloat
    
    var body: some View {
        Button(action: toggle) {
            Text(verbatim: value)
                .font(.roboto(size: viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 12)))
                .foregroundStyle(.gray)
        }
        .accessibilityLabel("!Channel name")
        .buttonStyle(.plain)
    }
    
    func toggle() {
        withAnimation {
            viewModel.showChannelName.toggle()
        }
    }
}

#Preview {
    ChannelTitleView(
        value: "Benjamin Code",
        thumbnailWidth: 350
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
