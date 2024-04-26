//
//  ContentView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    var body: some View {
#if os(macOS)
        NavigationSplitView {
            LastUrlsListView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 200, max: 300)
        } detail: {
            ThumbnailMakerView()
                .navigationTitle("!Youtube Minia Maker")
        }
#else
        NavigationStack {
            ThumbnailMakerView()
                .navigationTitle("!Youtube Minia Maker")
        }
#endif
        
    }
}

#Preview {
    ContentView()
#if os(macOS)
        .frame(width: 800, height: 500)
#endif
        .dataContainer(inMemory: true)
        .generateMoc()
        .environmentObject(ThumbnailMakerViewModel.shared)
}
