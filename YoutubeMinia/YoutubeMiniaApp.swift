//
//  YoutubeMiniaApp.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import SwiftUI
import SwiftData

@main
struct YoutubeMiniaApp: App {
    
    @StateObject private var thumbnailMakerViewModel = ThumbnailMakerViewModel.shared
    
    var body: some Scene {
        Window("!Youtube minia", id: WindowId.main.rawValue) {
            ContentView()
                .dataContainer()
                .environmentObject(thumbnailMakerViewModel)
                .frame(width: 800, height: 500)
                .navigationTitle("!Youtube Thumbnail Maker")
        }
        .defaultSize(width: 800, height: 500)
        .windowResizability(.contentSize)
        
        Settings {
            NavigationStack {
                PreferencesView()
            }
            .environmentObject(thumbnailMakerViewModel)
        }
        .windowResizability(.contentSize)
        
        MenuBarExtra("!Youtube minia", systemImage: "photo.badge.arrow.down") {
            MenuBarExtraView()
                .environmentObject(thumbnailMakerViewModel)
        }
        .menuBarExtraStyle(.menu)
//        .menuBarExtraAccess(isPresented: $appState.isMenuPresented)
    }
}
