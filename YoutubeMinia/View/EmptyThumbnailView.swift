//
//  EmptyThumbnailView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 26/04/2024.
//

import SwiftUI

struct EmptyThumbnailView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    var width: CGFloat = 350
    
    var body: some View {
        
        VStack(spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 12)) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    if let videoThumbnail = viewModel.videoThumbnail {
                        videoThumbnail
                            .resizable()
                            .scaledToFit()
                        
                    } else {
                        Image("videoThumbnail")
                            .resizable()
                            .scaledToFit()
                            .overlay {
                                Rectangle()
                                    .foregroundStyle(.gray.opacity(0.7))
                            }
                            .redacted(reason: .placeholder)
                    }
                }
                
                if viewModel.showDuration {
                    VideoDurationView(
                        value: "10:10",
                        thumbnailWidth: width
                    )
                    .redacted(reason: .placeholder)
                }
                
                if viewModel.showProgress {
                    VideoProgressView(
                        value: 0.5,
                        thumbnailWidth: width
                    )
                    .redacted(reason: .placeholder)
                }
            }
            .clipShape(
                RoundedRectangle(cornerRadius: viewModel.innerCornerRadius)
            )
            .thumbnailShadow(
                radius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8)
            )
            
            HStack(
                alignment: .top,
                spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 16)
            ) {
                if viewModel.showChannelIcon {
                    ChannelThumbnailView(
                        value: viewModel.channelThumbnail,
                        thumbnailWidth: width
                    )
                }
                
                VStack(
                    alignment: .leading,
                    spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)
                ) {
                    VideoTitleView(
                        value: "This is a video title",
                        thumbnailWidth: width
                    )
                    
                    VStack(
                        alignment: .leading,
                        spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)
                    ) {
                        if viewModel.showChannelName || viewModel.showChannelCount {
                            HStack(spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)) {
                                if viewModel.showChannelName {
                                    ChannelTitleView(
                                        value: "My channel",
                                        thumbnailWidth: width
                                    )
                                }
                                if viewModel.showChannelName && viewModel.showChannelCount {
                                    Text(verbatim: "-")
                                }
                                if viewModel.showChannelCount {
                                    ChannelSubCountView(
                                        value: "200000",
                                        thumbnailWidth: width
                                    )
                                }
                            }
                        }
                        if viewModel.showViewCount || viewModel.showPublishDate {
                            HStack(spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)) {
                                if viewModel.showViewCount {
                                    VideoViewCountView(
                                        value: "404000",
                                        thumbnailWidth: width
                                    )
                                }
                                if viewModel.showViewCount && viewModel.showPublishDate {
                                    Text(verbatim: "-")
                                }
                                if viewModel.showPublishDate {
                                    VideoPublishDateView(
                                        value: .now,
                                        thumbnailWidth: width
                                    )
                                }
                            }
                        }
                    }
                    .font(.roboto(size: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 12)))
                    .foregroundStyle(.gray)
                }
                .redacted(reason: .placeholder)
            }
            .padding(.horizontal, viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: width)
        .padding([.horizontal, .top], viewModel.thumbnailPadding)
        .padding(.bottom, viewModel.bottomPadding)
        .background(viewModel.isDarkTheme ? .black.opacity(0.88) : .white, in: RoundedRectangle(cornerRadius: viewModel.outerCornerRadius))
        .thumbnailShadow(radius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8))
        .padding(viewModel.responsiveFontSize(currentWidth: width, referenceSize: 16))
    }
}

#Preview {
    EmptyThumbnailView()
        .environmentObject(ThumbnailMakerViewModel.shared)
}
