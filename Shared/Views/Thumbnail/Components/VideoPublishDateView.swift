//
//  VideoPublishDateView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI

struct VideoPublishDateView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    let value: Date
    let thumbnailWidth: CGFloat
    
    var body: some View {
        Button(action: toggle) {
            Text(verbatim: value.formatPublicationDate())
                .font(.roboto(size: viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 12)))
                .foregroundStyle(.gray)
        }
        .accessibilityLabel("!Video publish date")
        .buttonStyle(.plain)
    }
    
    func toggle() {
        withAnimation {
            viewModel.showPublishDate.toggle()
        }
    }
}

#Preview {
    VideoPublishDateView(
        value: .now,
        thumbnailWidth: 350
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
