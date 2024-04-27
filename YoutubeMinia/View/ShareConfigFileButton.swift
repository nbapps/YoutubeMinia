//
//  ShareConfigFileButton.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI

#if os(macOS)
struct ShareConfigFileButton: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    var padding: CGFloat = 0
    @Binding var saveConfigFile: Bool
    
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        Button {
            saveConfigFile.toggle()
        } label: {
            Label("!Save .yttm file", systemImage: "doc.badge.arrow.up")
                .padding(padding)
        }
        .disabled(viewModel.ymThumbnailData == nil)
        .disabled(viewModel.isFetching)
    }
}

#Preview {
    ShareConfigFileButton(
        saveConfigFile: .constant(false),
        showError: .constant(false),
        errorMessage: .constant("")
    )
    .environmentObject(ThumbnailMakerViewModel.preview)
}
#endif
