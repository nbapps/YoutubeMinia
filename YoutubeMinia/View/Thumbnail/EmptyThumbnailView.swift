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
                            .scaledToFill()
                        
                    } else {
                        Image("videoThumbnail")
                            .resizable()
                            .scaledToFill()
                            .overlay {
                                Rectangle()
                                    .foregroundStyle(.gray.opacity(0.7))
                            }
                            .redacted(reason: .placeholder)
                    }
                }
                
                VStack(alignment: .trailing, spacing: 0) {
                    VideoDurationView(
                        value: "10:10",
                        thumbnailWidth: width
                    )
                    .opacity(viewModel.showDuration ? 1 : 0)
                    
                    if viewModel.showProgress {
                        VideoProgressView(
                            value: viewModel.lastProgress,
                            thumbnailWidth: width
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .redacted(reason: .placeholder)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: viewModel.innerCornerRadius))
            )
            .thumbnailShadow(
                radius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)
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
        .padding(viewModel.responsiveFontSize(currentWidth: width, referenceSize: viewModel.thumbnailPadding))
        .background(viewModel.isDarkTheme ? .black.opacity(0.88) : .white, in: RoundedRectangle(cornerRadius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: viewModel.outerCornerRadius)))
        .thumbnailShadow(radius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8))
        .padding(viewModel.responsiveFontSize(currentWidth: width, referenceSize: 16))
    }
}

#Preview {
    EmptyThumbnailView(width: 350)
        .scaledToFit()
        .frame(width: 350)
        .environmentObject(ThumbnailMakerViewModel.shared)
}
