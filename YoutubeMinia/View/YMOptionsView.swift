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
            Text("!Options")
#if os(macOS)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
#else
                .font(.title)
                .fontWeight(.bold)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
#endif

                Section {
                    Toggle("!Show video duration", isOn: $viewModel.showDuration.animation())
                    Toggle("!Show views count", isOn: $viewModel.showViewCount.animation())
                    Toggle("!Show publication date", isOn: $viewModel.showPublishDate.animation())
                }
                
                
                Section {
                    Toggle("!Show channel icon", isOn: $viewModel.showChannelIcon.animation())
                    Toggle("!Show channel name", isOn: $viewModel.showChannelName.animation())
                    Toggle("!Show channel sub", isOn: $viewModel.showChannelCount.animation())
                }
                
            Section {
                Toggle("!Dark theme", isOn: $viewModel.isDarkTheme.animation())
            }
                
            Section {
                Toggle("!Show progress bar", isOn: $viewModel.showProgress.animation())
                ProgressBar(title: String(localized: "!Progress"), progress: $viewModel.lastProgress)
                    .onChange(of: viewModel.lastProgress) { _, newValue in
                        viewModel.showProgress = newValue != 0
                    }
            }
                
            Section {
                ProgressBar(title: String(localized: "!Corner radius"), progress: $viewModel.thumbnailCornerRadius)
                ProgressBar(title: String(localized: "!Thumbnail padding"), progress: $viewModel.thumbnailPadding, showValue: false, range: 8...20, step: 1)
            }
            
            Section {
                Picker("!Export scale", selection: $viewModel.exportSize) {
                    ForEach(ExportScale.allCases) {
                        Text($0.rawValue)
                    }
                }
            }
            
            Section {
                Toggle("!Apply options when select previous url", isOn: $viewModel.applySavedSettingsOnSelectFromHistory)
            }
        }
        .toggleStyle(.switch)
    }
}

#Preview {
    YMOptionsView()
        .environmentObject(ThumbnailMakerViewModel.shared)
}
