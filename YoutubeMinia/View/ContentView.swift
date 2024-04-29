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
            macBody
#else
            if UIDevice.current.isPad {
                iPadBody
            } else {
                iPhoneBody
            }
#endif
        }
        .onChange(of: scenePhase) { _, _ in
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    var macBody: some View {
        NavigationSplitView {
            LastUrlsListView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 200, max: 300)
        } detail: {
            ThumbnailMakerView()
                .navigationTitle("!Youtube Minia Maker")
        }
    }
    
    var iPadBody: some View {
        NavigationSplitView {
            LastUrlsListView()
        } detail: {
            ThumbnailMakerView()
                .navigationTitle("!Youtube Minia Maker")
        }
    }
    
    var iPhoneBody: some View {
        NavigationStack {
            ThumbnailMakerView()
                .navigationTitle("!Youtube Minia Maker")
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
