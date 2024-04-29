//
//  ThumbnailMakerView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData
import StoreKit

struct ThumbnailMakerView: View {
    @Environment(\.requestReview) var requestReview
    
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
#if os(macOS)
    @State private var showInspector = true
#else
    @State private var showInspector = false
#endif
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var saveConfigFile = false
    @State private var showImportFile = false
    
    @Query(sort: [SortDescriptor(\PreviousURL.timestamp, order: .reverse)])
    private var previousURLs: [PreviousURL]
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ScrollView {
                    if showError {
                        Text(errorMessage.isEmpty ? "Error" : errorMessage)
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                TextField(text: $viewModel.videoURlStr) {
                                    Text(verbatim: "https://www.youtube.com/watch?v=f7_CHu0ADhM")
                                }
                                .textFieldStyle(.roundedBorder)
                                .onSubmit(fetch)
                                
                                Button {
                                    viewModel.videoURlStr = ""
                                    viewModel.ymThumbnailData = nil
                                    viewModel.videoThumbnail = nil
                                    viewModel.channelThumbnail = nil
                                } label: {
                                    Image(systemName: "xmark")
                                }
                                .buttonStyle(.plain)
                                .disabled(viewModel.videoURlStr.isEmpty)
                            }
                            
                            Text("!Any Youtube URL")
                                .padding(.horizontal, 12)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(8)
                    }
                    
                    Section {
                        VStack {
                            ThumbnailViewOrEmpty(width: proxy.size.width)
                            if viewModel.ymThumbnailData == nil {
                                Text("!Enter YouTube video URL to generate sharable thumbnail")
                            }
                        }
                    }
                    
                    Section {
                        HiddenComponents(width: proxy.size.width)
                            .padding()
                    }
                    
                    // TODO: refactor, add drag and export and save in BDD
                    
                    let width = proxy.size.width
                    Section {
                        HStack(
                            alignment: .center,
                            spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8)
                        ) {
                            ChannelThumbnailView(
                                value: viewModel.channelThumbnail,
                                thumbnailWidth: width
                            )
                            
                            VStack(
                                alignment: .leading,
                                spacing: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 4)
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
                            .font(.roboto(size: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 12)))
                            .foregroundStyle(.primary)
                        }
                        .padding(.leading, viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8))
                        .padding(.trailing, viewModel.responsiveFontSize(currentWidth: width, referenceSize: 16))
                        .padding(.vertical, viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8))
                        .background(viewModel.isDarkTheme ? .black.opacity(0.88) : .white, in: Capsule())
                        .thumbnailShadow(radius: viewModel.responsiveFontSize(currentWidth: width, referenceSize: 8))
                        .padding(viewModel.responsiveFontSize(currentWidth: width, referenceSize: 16))
                    }
                    
                    
                }
                if viewModel.isFetching {
                    ProgressView()
                }
            }
        }
        .frame(minWidth: 300)
        .inspectorOrModale(
            showInspector: $showInspector,
            disabled: viewModel.isFetching
        )
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            makeSaveButton()
            
            CopyImageButtonView(
                showError: $showError,
                errorMessage: $errorMessage
            )

#if os(macOS)
            ShareConfigFileButton(
                saveConfigFile: $saveConfigFile,
                showError: $showError,
                errorMessage: $errorMessage
            )
#endif
            
            Button {
                showInspector.toggle()
            } label: {
                Image(systemName: "switch.2")
            }
        }
        .disabled(viewModel.isFetching)
        .onDrop(of: [.item], isTargeted: nil, perform: viewModel.processOnDrop)
        .onOpenURL(perform: { url in
            if url.pathExtension == "yttm", let data = try? Data(contentsOf: url), let decoded = try? JSONDecoder().decode(SharableFile.self, from: data) {
                viewModel.importeConfigurationFile(decoded)
            }
        })
        .fileExporter(
            isPresented: $saveConfigFile,
            item: viewModel.configurationFile(),
            contentTypes: [.ymSharableFileExportType],
            defaultFilename: viewModel.ymThumbnailData?.videoTitle.formatFileName() ?? Date.now.ISO8601Format()
        ) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .onChange(of: viewModel.videoURlStr) { _, newValue in
            guard newValue.isNotEmpty else { return }
            #if !DEBUG
            requestReview()
            #endif
        }
    }
}

private extension ThumbnailMakerView {
    @ViewBuilder
    func makeSaveButton(padding: CGFloat = 0) -> some View {
#if os(macOS)
        SaveInDownloadButton(
            padding: padding,
            showError: $showError,
            errorMessage: $errorMessage
        )
#else
        SaveToPhotoLibraryButtonView(
            padding: padding,
            showError: $showError,
            errorMessage: $errorMessage
        )
#endif
    }
}
private extension ThumbnailMakerView {
    func fetch() {
        Task {
            do {
                try await viewModel.fetch()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func inspectorOrModale(showInspector: Binding<Bool>, disabled: Bool) -> some View {
#if os(macOS)
        inspector(isPresented: showInspector) {
            YMOptionsView()
                .disabled(disabled)
        }
#else
        if UIDevice.current.isPad {
            inspector(isPresented: showInspector) {
                YMOptionsView()
                    .disabled(disabled)
                    .inspectorColumnWidth(300)
            }
        } else {
            sheet(isPresented: showInspector) {
                YMOptionsWithPreview()
                    .disabled(disabled)
            }
        }
#endif
    }
}

#Preview {
    NavigationStack {
        ThumbnailMakerView()
    }
#if os(macOS)
        .frame(width: 800, height: 500)
#endif
        .dataContainer(inMemory: true)
        .environmentObject(ThumbnailMakerViewModel.preview)
}
