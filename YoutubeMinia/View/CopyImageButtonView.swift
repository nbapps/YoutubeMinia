//
//  CopyImageButtonView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI

struct CopyImageButtonView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    var padding: CGFloat = 0
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        Button {
            guard let thumbnailData = viewModel.ymThumbnailData else { return }
            
            Task { @MainActor in
                viewModel.copy(viewModel.renderThumbnail())
            }
        } label: {
            Label("!Copy", systemImage: "doc.on.doc")
                .padding(padding)
        }
        .keyboardShortcut("2")
        .disabled(viewModel.ymThumbnailData == nil)
        .disabled(viewModel.isFetching)
    }
}

#Preview {
    CopyImageButtonView(
        showError: .constant(false),
        errorMessage: .constant("")
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
