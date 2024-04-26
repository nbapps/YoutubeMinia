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
        NavigationStack {
            ThumbnailMakerView()
                .navigationTitle("!Youtube Minia Maker")
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 800, height: 500)
        .dataContainer(inMemory: true)
        .environmentObject(ThumbnailMakerViewModel.shared)
}
