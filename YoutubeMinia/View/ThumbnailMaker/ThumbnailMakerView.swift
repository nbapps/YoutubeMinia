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
    @State private var showInspector = true
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var saveConfigFile = false
    @State private var showImportFile = false
    
    var body: some View {
        ZStack {
            ScrollView {
                if showError {
                    Text(errorMessage.isEmpty ? "Error" : errorMessage)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            TextField("https://www.youtube.com/watch?v=f7_CHu0ADhM", text: $viewModel.videoURlStr)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit(fetch)
                            Button {
                                viewModel.videoURlStr = ""
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
                .listRowSeparator(.hidden)
                
                Section {
                    if let thumbnailData = viewModel.ymThumbnailData {
                        VStack {
                            ThumbnailView(thumbnailData: thumbnailData)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .draggableIfAllow(
                                    image: ThumbnailView(thumbnailData: thumbnailData)
                                        .environmentObject(viewModel)
                                        .getScaledImage()
                                        .nsImage
                                )
                            
                            HStack {
                                SaveInDownloadButton(
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
                            .buttonStyle(.borderedProminent)
                            
                            shareFileButton(padding: 8)
                                .buttonStyle(.borderedProminent)
                        }
                    } else {
                        VStack {
                            EmptyThumbnailView()
                            Text("!Enter YouTube video URL to generate sharable thumbnail")
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            if viewModel.isFetching {
                ProgressView()
            }
        }
        .inspector(isPresented: $showInspector) {
            YMOptionsView()
                .disabled(viewModel.isFetching)
        }
        .toolbar {
            SaveInDownloadButton(
                showError: $showError,
                errorMessage: $errorMessage
            )
            
            CopyImageButtonView(
                showError: $showError,
                errorMessage: $errorMessage
            )
            shareFileButton()
            
            Button {
                showInspector.toggle()
            } label: {
                Image(systemName: "rectangle.righthalf.inset.filled")
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
    func shareFileButton(padding: CGFloat = 0) -> some View {
        Button {
            saveConfigFile.toggle()
        } label: {
            Label("!Save .yttm file", systemImage: "doc.badge.arrow.up")
                .padding(padding)
        }
        .disabled(viewModel.ymThumbnailData == nil)
        .disabled(viewModel.isFetching)
    }
    
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
        .frame(width: 800, height: 500)
        .dataContainer(inMemory: true)
        .environmentObject(ThumbnailMakerViewModel.preview)
}
