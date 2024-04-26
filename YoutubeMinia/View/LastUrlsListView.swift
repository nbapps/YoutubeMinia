//
//  LastUrlsListView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 26/04/2024.
//

import SwiftUI
import SwiftData

struct LastUrlsListView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        sort: \PreviousURL.timestamp,
        order: .reverse
    )
    private var previousURLs: [PreviousURL]
    
    var body: some View {
        List(previousURLs) { previousURL in
            LastUrlsRowView(previousURL: previousURL)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        modelContext.delete(previousURL)
                    } label: {
                        Label("!Remove", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        viewModel.videoURlStr = previousURL.urlStr
                        withAnimation {
                            viewModel.selectedTab = .maker
                        }
                    } label: {
                        Label("!Make", systemImage: "photo")
                    }
                    .tint(.accentColor)
                }
                .listSectionSpacing(8)
        }
    }
}

#Preview {
    LastUrlsListView()
        .dataContainer(inMemory: true)
        .generateMoc()
}
