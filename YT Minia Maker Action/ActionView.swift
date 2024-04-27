//
//  ActionView.swift
//  YT Minia Maker Action
//
//  Created by Nicolas Bachur on 27/04/2024.
//

import SwiftUI

struct ActionView: View {
    @StateObject var actionViewModel: ActionViewModel
    @StateObject var thumbnailMakerViewModel: ThumbnailMakerViewModel

    @State private var showError = false
    @State private var errorMessage = ""
    
    let onClose: () -> Void
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack {
                    ScrollView {
                        if showError {
                            Text(errorMessage.isEmpty ? "Error" : errorMessage)
                        }
                        
                        Section {
                            Text(verbatim: thumbnailMakerViewModel.videoURlStr)
                                .lineLimit(2)
                            .padding(8)
                        }
                        
                        Section {
                            if let thumbnailData = thumbnailMakerViewModel.ymThumbnailData {
                                VStack {
                                    ThumbnailView(thumbnailData: thumbnailData, width: proxy.size.width * 0.8)
                                    //                                    .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                        .draggableIfAllow(
                                            image: ThumbnailView(thumbnailData: thumbnailData)
                                                .environmentObject(thumbnailMakerViewModel)
                                                .getScaledImage(scale: thumbnailMakerViewModel.exportSize.scale)
                                                .appImage
                                        )
                                }
                            } else {
                                VStack {
                                    EmptyThumbnailView(width: proxy.size.width * 0.8)
                                    Text("!Enter YouTube video URL to generate sharable thumbnail")
                                }
                            }
                        }
                        
                        Section {
                            HiddenComponents(width: proxy.size.width * 0.8)
                                .padding()
                        }
                        
                        Section {
                            SaveToPhotoLibraryButtonView(
                                padding: 8,
                                showError: $showError,
                                errorMessage: $errorMessage
                            )
                            CopyImageButtonView(
                                padding: 8,
                                showError: $showError,
                                errorMessage: $errorMessage
                            )
                        }
                    }
                    .disabled(!actionViewModel.isValidYTURL)
                    .blur(radius: actionViewModel.isValidYTURL ? 0 : 10)
                    .opacity(actionViewModel.isValidYTURL ? 1 : 0.8)

                    if thumbnailMakerViewModel.isFetching {
                        ProgressView()
                    }
                    
                    if !actionViewModel.isValidYTURL {
                        Text("!This URL does not appear to be a valid YouTube URL")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundStyle(.red)
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                            .thumbnailShadow(radius: 6)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) {
                        Text("!Close")
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("!Thumbnail")
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding(.horizontal)
        .environmentObject(thumbnailMakerViewModel)
    }
}

#Preview {
    ActionView(
        actionViewModel: ActionViewModel(),
        thumbnailMakerViewModel: ThumbnailMakerViewModel.preview,
        onClose: {}
    )
//    .environmentObject(ThumbnailMakerViewModel.preview)
}
