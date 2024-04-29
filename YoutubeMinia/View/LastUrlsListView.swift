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
        order: .reverse,
        animation: .easeInOut
    )
    private var previousURLs: [PreviousURL]
    
    var body: some View {
        List(previousURLs) { previousURL in
            LastUrlsRowView(previousURL: previousURL)
        }
    }
}

#Preview {
    LastUrlsListView()
        .dataContainer(inMemory: true)
        .generateMoc()
}
