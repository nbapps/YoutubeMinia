//
//  YMOptionsWithPreview.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 28/04/2024.
//

import SwiftUI

struct YMOptionsWithPreview: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 8) {
                VStack(alignment: .leading) {
                    Text("!Options")
                        .safeAreaPadding(.top, proxy.safeAreaInsets.top + 16)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    
                    ThumbnailViewOrEmpty(width: proxy.size.width)
                        .padding(8)
                }
                .zIndex(1)
                
                .ignoresSafeArea()
                
                YMOptionsView()
                    .contentMargins(.bottom, 44, for: .scrollContent)
            }
            .background(.background.secondary)
        }
    }
}

#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            YMOptionsWithPreview()
        }
        .environmentObject(ThumbnailMakerViewModel.preview)
}
