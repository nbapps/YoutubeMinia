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

    @State private var showSheet = false
    
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
                            ThumbnailViewOrEmpty(width: proxy.size.width)
                        }
                        
                        Section {
                            HiddenComponents(width: proxy.size.width)
                                .padding()
                        }
                    }
                    .contentMargins(.bottom, 100, for: .scrollContent)
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
                    
                    VStack {
                        Spacer()
                        SaveToPhotoLibraryButtonView(
                            padding: 8,
                            showError: $showError,
                            errorMessage: $errorMessage
                        )
                        .buttonStyle(.borderedProminent)
                        .padding()
                        .padding(.bottom, 20)
                    }
                    .disabled(!actionViewModel.isValidYTURL)
                    .blur(radius: actionViewModel.isValidYTURL ? 0 : 10)
                    .opacity(actionViewModel.isValidYTURL ? 1 : 0.8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if actionViewModel.isValidYTURL {
                        Menu("!Close") {
                            SaveToPhotoLibraryButtonView(
                                padding: 8,
                                showError: $showError,
                                errorMessage: $errorMessage
                            )
                            
                            Divider()
                            Button(role: .destructive, action: onClose) {
                                Label("!Close", systemImage: "xmark")
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: onClose) {
                            Text("!Close")
                                .padding(.horizontal)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSheet.toggle()
                    } label: {
                        Image(systemName: "switch.2")
                            .padding(.horizontal)
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
                YMOptionsWithPreview()
                    .disabled(thumbnailMakerViewModel.isFetching)
            }
            .padding(.horizontal)
            .navigationTitle("!Thumbnail")
            .navigationBarTitleDisplayMode(.inline)
        }
        .environmentObject(thumbnailMakerViewModel)
    }
}

#Preview {
    ActionView(
        actionViewModel: ActionViewModel(),
        thumbnailMakerViewModel: ThumbnailMakerViewModel.preview,
        onClose: {}
    )
}
