//
//  ChannelBadgeView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 03/05/2024.
//

import SwiftUI

struct ChannelBadgeView: View, Responsive {
    @EnvironmentObject var viewModel: ThumbnailMakerViewModel
    
    init(width: CGFloat) {
        self.width = min(width, 500)
    }
    
    let width: CGFloat
    
    var body: some View {
        HStack(
            alignment: .center,
            spacing: spacing8
        ) {
            Text(12300, format: .number.notation(.compactName))
            ChannelThumbnailView(
                value: viewModel.channelThumbnail,
                thumbnailWidth: width
            )
            
            VStack(
                alignment: .leading,
                spacing: spacing4
            ) {
                
                ChannelTitleView(
                    value: viewModel.ymChannelData?.channelTitle ?? "My Channel",
                    thumbnailWidth: width
                )
                ChannelSubCountView(
                    value: viewModel.ymChannelData?.channelCount ?? "200000",
                    thumbnailWidth: width
                )
            }
            .font(.roboto(size: spacing12))
            .foregroundStyle(.primary)
        }
        .padding(.leading, spacing8)
        .padding(.trailing, spacing16)
        .padding(.vertical,spacing8)
        .background(viewModel.isDarkTheme ? .black.opacity(0.88) : .white, in: .rect(cornerRadii: RectangleCornerRadii(topLeading: .infinity, bottomLeading: .infinity,
                                                                                                                       bottomTrailing: spacing16, topTrailing: spacing16)
        ))
//        .background(viewModel.isDarkTheme ? .black.opacity(0.88) : .white, in: Capsule())
        .thumbnailShadow(radius: spacing8)
        .padding(spacing16)
    }
}

#Preview {
    ChannelBadgeView(
        width: 300
    )
    .background(Color.red)
    .environmentObject(ThumbnailMakerViewModel.preview)
}

protocol Responsive {
    var viewModel: ThumbnailMakerViewModel { get }
    var width: CGFloat { get }
}

extension Responsive {
    var spacing4: CGFloat {
        viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)
    }
    
    var spacing8: CGFloat {
        viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8)
    }
    
    var spacing10: CGFloat {
        viewModel.responsiveFontSize(currentWidth: width, referenceSize: 10)
    }
    
    var spacing12: CGFloat {
        viewModel.responsiveFontSize(currentWidth: width, referenceSize: 12)
    }
    
    var spacing16: CGFloat {
        viewModel.responsiveFontSize(currentWidth: width, referenceSize: 16)
    }
}
