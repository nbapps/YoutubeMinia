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
                    Text("10:10")
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
                        .redacted(reason: .placeholder)
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
                    Text("This is a video title")
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
                                Text("My channel")
                            }
                            if viewModel.showChannelName && viewModel.showChannelCount {
                                Text(verbatim: "-")
                            }
                            if viewModel.showChannelCount {
                                Text("200000".formatChannelCount())
                            }
                        }
                        HStack(spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)) {
                            if viewModel.showViewCount {
                                Text("404000".formatViewCount())
                            }
                            if viewModel.showViewCount && viewModel.showPublishDate {
                                Text(verbatim: "-")
                            }
                            if viewModel.showPublishDate {
                                Text(Date.now.formatPublicationDate())
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
