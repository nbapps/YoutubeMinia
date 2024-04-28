//
//  HiddenComponents.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI

struct HiddenComponents: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    var width: CGFloat = 350
    
    var body: some View {
        VStack(spacing: 16) {
            Text("!Hidden components")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            if viewModel.allComponentsDisplayed {
                Text("!Click on a component in the thumbnail to hide it. e.g. channel thumbnail")
            }
            
            if !viewModel.showDuration {
                VideoDurationView(
                    value: viewModel.ymThumbnailData?.videoDuration ?? "10:10",
                    thumbnailWidth: width
                )
            }
            
            if !viewModel.showProgress {
                VideoProgressView(
                    value: viewModel.lastProgress,
                    thumbnailWidth: width
                )
            }
            
            HStack(
                alignment: .top,
                spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 16)
            ) {
                if !viewModel.showChannelIcon {
                    ChannelThumbnailView(
                        value: viewModel.channelThumbnail,
                        thumbnailWidth: width
                    )
                }
                
                VStack(
                    alignment: .leading,
                    spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)
                ) {
                    
                    VStack(
                        alignment: .leading,
                        spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)
                    ) {
                        HStack(spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)) {
                            if !viewModel.showChannelName {
                                ChannelTitleView(
                                    value: viewModel.ymThumbnailData?.channelTitle ?? "My Channel",
                                    thumbnailWidth: width
                                )
                            }
                            if !viewModel.showChannelName && !viewModel.showChannelCount {
                                Text(verbatim: "-")
                            }
                            if !viewModel.showChannelCount {
                                ChannelSubCountView(
                                    value: viewModel.ymThumbnailData?.channelCount ?? "200000",
                                    thumbnailWidth: width
                                )
                            }
                        }
                        HStack(spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)) {
                            if !viewModel.showViewCount {
                                VideoViewCountView(
                                    value: viewModel.ymThumbnailData?.viewCount ?? "404000",
                                    thumbnailWidth: width
                                )
                            }
                            if !viewModel.showViewCount && !viewModel.showPublishDate {
                                Text(verbatim: "-")
                            }
                            if !viewModel.showPublishDate {
                                VideoPublishDateView(
                                    value: viewModel.ymThumbnailData?.publicationDate ?? Date(timeIntervalSinceNow: -3600),
                                    thumbnailWidth: width
                                )
                            }
                        }
                    }
                    .font(.roboto(size: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 12)))
                    .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal, viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    HiddenComponents()
        .environmentObject(ThumbnailMakerViewModel.preview)
}
