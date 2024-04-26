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
                        Text(thumbnailData.videoDuration)
                            .font(.roboto(weight: .medium, size: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 12)))
                            .foregroundStyle( .white)
                            .padding(
                                .horizontal,
                                viewModel.responsiveFontSize(currentWidth: width, referenceSize: 6)
                            )
                            .padding(
                                .vertical,
                                viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)
                            )
                            .background(
                                .black.opacity(0.5),
                                in: RoundedRectangle(
                                    cornerRadius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 6)
                                )
                            )
                            .padding(viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8))
                    }
                    
                    if viewModel.showProgress {
                        RoundedRectangle(
                            cornerRadius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8)
                        )
                        .frame(
                            width: width * viewModel.lastProgress,
                            height: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 5),
                            alignment: .leading
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.red)
                        .padding(
                            .bottom,
                            viewModel.responsiveFontSize(currentWidth: width, referenceSize: 1)
                        )
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
                        ZStack {
                            if let channelThumbnail = viewModel.channelThumbnail {
                                channelThumbnail
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .thumbnailShadow()
                            } else {
                                ProgressView()
                                    .scaledToFit()
                                    .clipShape(Circle())
                            }
                        }
                        .frame(width: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 40))
                    }
                    
                    VStack(
                        alignment: .leading,
                        spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)
                    ) {
                        Text(thumbnailData.videoTitle)
                            .multilineTextAlignment(.leading)
                            .font(.roboto(weight: .medium, size: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 14)))
                            .foregroundStyle(viewModel.isDarkTheme ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                        
                        VStack(
                            alignment: .leading,
                            spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)
                        ) {
                            HStack(spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)) {
                                if viewModel.showChannelName {
                                    Text(thumbnailData.channelTitle)
                                }
                                if viewModel.showChannelName && viewModel.showChannelCount {
                                    Text(verbatim: "-")
                                }
                                if viewModel.showChannelCount {
                                    Text(thumbnailData.channelCount.formatChannelCount())
                                }
                            }
                            HStack(spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)) {
                                if viewModel.showViewCount {
                                    Text(thumbnailData.viewCount.formatViewCount())
                                }
                                if viewModel.showViewCount && viewModel.showPublishDate {
                                    Text(verbatim: "-")
                                }
                                if viewModel.showPublishDate {
                                    Text(thumbnailData.publicationDate.formatPublicationDate())
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
            .padding([.horizontal, .top], viewModel.thumbnailPadding)
            .padding(.bottom, viewModel.bottomPadding)
            .background(viewModel.isDarkTheme ? .black.opacity(0.88) : .white, in: RoundedRectangle(cornerRadius: viewModel.outerCornerRadius))
            .shadow(color: .clear, radius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 10))
            .thumbnailShadow(radius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8))
            .padding(viewModel.responsiveFontSize(currentWidth: width, referenceSize: 16))
        }
    }
}

#Preview {
    ThumbnailView(thumbnailData: .moc)
        .environmentObject(ThumbnailMakerViewModel.shared)
}
