//
//  ThumbnailView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI

struct ThumbnailView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    let thumbnailData: YMThumbnailData?
    
    var width: CGFloat = 350
    
    var body: some View {
        if let thumbnailData {
            VStack(spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 12)) {
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        if let videoThumbnail = viewModel.videoThumbnail {
                            videoThumbnail
                                .resizable()
                                .scaledToFit()
                        } else {
                            ZStack {
                                Image("videoThumbnail")
                                    .resizable()
                                    .scaledToFit()
                                    .opacity(0.1)
                                ProgressView()
                            }
                        }
                    }
                    
                    if viewModel.showDuration {
                        VideoDurationView(
                            value: thumbnailData.videoDuration,
                            thumbnailWidth: width
                        )
                    }
                    
                    if viewModel.showProgress {
                        VideoProgressView(
                            value: viewModel.lastProgress,
                            thumbnailWidth: width
                        )
                    }
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: viewModel.innerCornerRadius))
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
                            value: thumbnailData.videoTitle,
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
                                            value: thumbnailData.channelTitle,
                                            thumbnailWidth: width
                                        )
                                    }
                                    if viewModel.showChannelName && viewModel.showChannelCount {
                                        Text(verbatim: "-")
                                    }
                                    if viewModel.showChannelCount {
                                        ChannelSubCountView(
                                            value: thumbnailData.channelCount,
                                            thumbnailWidth: width
                                        )
                                    }
                                }
                            }
                            
                            if viewModel.showViewCount || viewModel.showPublishDate {
                                HStack(spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)) {
                                    if viewModel.showViewCount {
                                        VideoViewCountView(
                                            value: thumbnailData.viewCount,
                                            thumbnailWidth: width
                                        )
                                    }
                                    if viewModel.showViewCount && viewModel.showPublishDate {
                                        Text(verbatim: "-")
                                    }
                                    if viewModel.showPublishDate {
                                        VideoPublishDateView(
                                            value: thumbnailData.publicationDate,
                                            thumbnailWidth: width
                                        )
                                    }
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
            .frame(width: width)
            .padding([.horizontal, .top], viewModel.responsiveFontSize(currentWidth: width, referenceSize: viewModel.thumbnailPadding))
            .padding(.bottom, viewModel.responsiveFontSize(currentWidth: width, referenceSize: viewModel.bottomPadding))
            .background(viewModel.isDarkTheme ? .black.opacity(0.88) : .white, in: RoundedRectangle(cornerRadius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: viewModel.outerCornerRadius)))
            .shadow(color: .clear, radius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 10))
            .thumbnailShadow(radius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8))
            .padding(viewModel.responsiveFontSize(currentWidth: width, referenceSize: 16))
        }
    }
}

#Preview {
    ThumbnailView(thumbnailData: .moc)
        .environmentObject(ThumbnailMakerViewModel.preview)
}
