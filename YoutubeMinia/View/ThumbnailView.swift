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
    
    private let width: CGFloat = 350
    
    var body: some View {
        if let thumbnailData {
            VStack(spacing: 12) {
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
                            .font(.roboto(weight: .medium, size: 12))
                            .foregroundStyle( .white)
                            .padding(EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6))
                            .background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
                            .padding(8)
                    }
                    
                    if viewModel.showProgress {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: width * viewModel.lastProgress, height: 5, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.red)
                            .padding(.bottom, 1)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: innerCornerRadius))
                .thumbnailShadow(radius: 8)
                
                HStack(alignment: .top, spacing: 16) {
                    if viewModel.showChannelIcon {
                        ZStack {
                            if let channelThumbnail = viewModel.channelThumbnail {
                                channelThumbnail
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40)
                                    .clipShape(Circle())
                                    .thumbnailShadow()
                            } else {
                                ProgressView()
                                    .scaledToFit()
                                    .frame(width: 40)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(thumbnailData.videoTitle)
                            .multilineTextAlignment(.leading)
                            .font(.roboto(weight: .medium, size: 14))
                            .foregroundStyle(viewModel.isDarkTheme ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
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
                            HStack(spacing: 4) {
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
                        .font(.roboto(size: 12))
                        .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: width)
            .padding([.horizontal, .top], viewModel.thumbnailPadding)
            .padding(.bottom, bottomPadding)
            .background(viewModel.isDarkTheme ? .black.opacity(0.88) : .white, in: RoundedRectangle(cornerRadius: outerCornerRadius))
            .shadow(color: .clear, radius: 10)
            .thumbnailShadow(radius: 8)
            .padding(16)
        }
    }
    
    var innerCornerRadius: Double {
        viewModel.mapValue(viewModel.thumbnailCornerRadius, fromRange: 0...1, toRange: 8...20)
    }
    var outerCornerRadius: Double {
        (innerCornerRadius + viewModel.thumbnailPadding).rounded(.up)
    }
    
    var bottomPadding: Double {
        viewModel.mapValue(viewModel.thumbnailPadding, fromRange: 8...20, toRange: 8...16)
    }
}

#Preview {
    ThumbnailView(thumbnailData: .moc)
        .environmentObject(ThumbnailMakerViewModel.shared)
}
