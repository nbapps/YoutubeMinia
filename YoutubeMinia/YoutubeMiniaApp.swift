//
//  YoutubeMiniaApp.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct YoutubeMiniaApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .dataContainer()
                .environmentObject(YMViewModel.shared)
                .frame(width: 800, height: 500)
                .navigationTitle("!Youtube Thumbnail Maker")
        }
        .defaultSize(width: 800, height: 500)
        .windowResizability(.contentSize)
    }
}
