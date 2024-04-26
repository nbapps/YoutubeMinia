//
//  SaveInDownloadButton.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI

struct SaveInDownloadButton: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    var padding: CGFloat = 0
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        Button {
            guard let thumbnailData = viewModel.ymThumbnailData else { return }

            do {
                try viewModel.exportToDownloads(thumbnailData: thumbnailData)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        } label: {
            Label("!Save in Dowmloads", systemImage: "photo.badge.arrow.down")
                .padding(padding)
        }
        .keyboardShortcut("1")
        .disabled(viewModel.ymThumbnailData == nil)
        .disabled(viewModel.isFetching)
    }
}

#Preview {
    SaveInDownloadButton(
        showError: .constant(false), 
        errorMessage: .constant("")
    )
        .environmentObject(ThumbnailMakerViewModel.preview)
}
