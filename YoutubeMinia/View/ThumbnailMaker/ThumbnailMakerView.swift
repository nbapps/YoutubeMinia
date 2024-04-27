//
//  ThumbnailMakerView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ThumbnailMakerView: View {
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
                        if let thumbnailData = viewModel.ymThumbnailData {
                            VStack {
                                ThumbnailView(thumbnailData: thumbnailData, width: proxy.size.width * 0.8)
                                //                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                                    .draggableIfAllow(
                                        image: ThumbnailView(thumbnailData: thumbnailData)
                                            .environmentObject(viewModel)
                                            .getScaledImage(scale: viewModel.exportSize.scale)
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
                    
                }
                if viewModel.isFetching {
                    ProgressView()
                }
            }
        }
        .frame(minWidth: 300)
#if os(macOS)
        .inspector(isPresented: $showInspector) {
            YMOptionsView()
                .disabled(viewModel.isFetching)
        }
#else
        .sheet(isPresented: $showInspector) {
            YMOptionsView()
                .disabled(viewModel.isFetching)
        }
#endif
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

#Preview {
    ThumbnailMakerView()
#if os(macOS)
        .frame(width: 800, height: 500)
#endif
        .dataContainer(inMemory: true)
        .environmentObject(ThumbnailMakerViewModel.preview)
}
