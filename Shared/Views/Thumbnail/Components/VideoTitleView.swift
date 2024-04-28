//
//  VideoTitleView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI

struct VideoTitleView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    let value: String
    let thumbnailWidth: CGFloat
    
    var body: some View {
        Button(action: toggle) {
            Text(verbatim: value)
                .multilineTextAlignment(.leading)
                .font(.roboto(weight: .medium, size: viewModel.responsiveFontSize(currentWidth: thumbnailWidth, referenceSize: 14)))
                .foregroundStyle(viewModel.isDarkTheme ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
        }
        .accessibilityLabel("!Video title")
        .buttonStyle(.plain)
    }
    
    func toggle() {}
}

#Preview {
    VideoTitleView(
        value: "Quel abonné codera la meilleure solution?",
        thumbnailWidth: 350
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
