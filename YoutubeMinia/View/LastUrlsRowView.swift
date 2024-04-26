//
//  LastUrlsRowView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 26/04/2024.
//

import SwiftUI

struct LastUrlsRowView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    @Environment(\.modelContext) private var modelContext
    
    let previousURL: PreviousURL
    
    let networkService = NetworkService()
    
    @State private var image: Image?
    
    var body: some View {
        Button(action: onSelect) {
            Section {
                HStack(alignment: .top, spacing: 16) {
                    makeThumbnail()
                        .frame(width: 50)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(verbatim: previousURL.title)
                            .lineLimit(2)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Text(previousURL.urlStr)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                    }
                }
            } footer: {
                Text(previousURL.timestamp, style: .offset)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            do {
                let data = try await networkService.fetch(url: previousURL.thumbnailUrl)
                guard let appImage = AppImage(data: data) else { return }
                image = Image(appImage: appImage)
            } catch {
                print(error)
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                modelContext.delete(previousURL)
            } label: {
                Label("!Remove", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: onSelect) {
                Label("!Make", systemImage: "photo")
            }
            .tint(.accentColor)
        }
#if os(iOS)
        .listSectionSpacing(8)
#endif
    }
    
    @ViewBuilder
    func makeThumbnail() -> some View {
        if let image {
            image
                .resizable()
                .scaledToFit()
        } else {
            ProgressView()
        }
    }
    
    func onSelect() {
        viewModel.applySettings(from: previousURL)
        
        withAnimation {
            viewModel.selectedTab = .maker
        }
    }
}

#Preview {
    List {
        LastUrlsRowView(
            previousURL: try! PreviousURL.getMocItem()
        )
    }
    .dataContainer(inMemory: true)
    .generateMoc()
}
