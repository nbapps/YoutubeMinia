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
                                    .redacted(reason: .placeholder)
                                
                                ProgressView()
                            }
                        }
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: viewModel.innerCornerRadius))
                    )
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        VideoDurationView(
                            value: thumbnailData.videoDuration,
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
                    .clipShape(
                        RoundedRectangle(cornerRadius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: viewModel.innerCornerRadius + 0.5))
                    )
                }
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
            .padding(viewModel.responsiveFontSize(currentWidth: width, referenceSize: viewModel.thumbnailPadding))
            .background(viewModel.isDarkTheme ? .black.opacity(0.88) : .white, in: RoundedRectangle(cornerRadius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: viewModel.outerCornerRadius)))
            .thumbnailShadow(radius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8))
            .padding(viewModel.responsiveFontSize(currentWidth: width, referenceSize: 16))
        }
    }
}

#Preview {
    ThumbnailView(thumbnailData: .moc)
        .environmentObject(ThumbnailMakerViewModel.preview)
}
