//
//  SaveToPhotoLibraryButtonView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 26/04/2024.
//

import SwiftUI

#if os(iOS)
struct SaveToPhotoLibraryButtonView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    var padding: CGFloat = 0
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        Button {
            guard let thumbnailData = viewModel.ymThumbnailData else { return }
            Task { @MainActor in
                do {
                    try viewModel.saveInPhotoLibrary(thumbnailData: thumbnailData)
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        } label: {
            Label("!Save in Photo library", systemImage: "photo.badge.arrow.down")
                .padding(padding)
        }
        .keyboardShortcut("1")
        .disabled(viewModel.ymThumbnailData == nil)
        .disabled(viewModel.isFetching)
    }
}

#Preview {
    SaveToPhotoLibraryButtonView(
        showError: .constant(false),
        errorMessage: .constant("")
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
#endif
