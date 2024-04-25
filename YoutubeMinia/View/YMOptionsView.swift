//
//  YMOptionsView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI

struct YMOptionsView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    var body: some View {
        List {
            Section {
                Toggle("!Show video duration", isOn: $viewModel.showDuration.animation())
                Toggle("!Show channel icon", isOn: $viewModel.showChannelIcon.animation())
                Toggle("!Show channel name", isOn: $viewModel.showChannelName.animation())
                Toggle("!Show channel sub", isOn: $viewModel.showChannelCount.animation())
                Toggle("!Show views count", isOn: $viewModel.showViewCount.animation())
                Toggle("!Show publication date", isOn: $viewModel.showPublishDate.animation())
                Toggle("!Show progress bar", isOn: $viewModel.showProgress.animation())
                
                ProgressBar(title: String(localized: "!Progress"), progress: $viewModel.lastProgress.animation())
                    .onChange(of: viewModel.lastProgress) { _, newValue in
                        viewModel.showProgress = newValue != 0
                    }
                
                Toggle("!Dark theme", isOn: $viewModel.isDarkTheme.animation())
                
                ProgressBar(title: String(localized: "!Corner radius"), progress: $viewModel.thumbnailCornerRadius)
                ProgressBar(title: String(localized: "!Thumbnail padding"), progress: $viewModel.thumbnailPadding, showValue: false, range: 8...20, step: 1)
            } header: {
                Text("!Options")
            }
            .toggleStyle(.switch)
        }
    }
}

#Preview {
    YMOptionsView()
        .environmentObject(ThumbnailMakerViewModel.shared)
}
