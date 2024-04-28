//
//  ContentView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import SwiftUI
import SwiftData
import Combine
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    
    var body: some View {
        Group {
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
        .onChange(of: scenePhase) { _, _ in
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
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
