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
    @Query private var items: [Item]

    @EnvironmentObject private var viewModel: YMViewModel

    var body: some View {
        NavigationStack {
            ThumbnailMakerView()
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 800, height: 500)
        .dataContainer(inMemory: true)
        .environmentObject(YMViewModel.shared)
}
