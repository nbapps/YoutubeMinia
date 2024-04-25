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
    var body: some Scene {
        Window("Youtube minia", id: "Main") {
            ContentView()
                .dataContainer()
                .environmentObject(ThumbnailMakerViewModel.shared)
                .frame(width: 800, height: 500)
                .navigationTitle("!Youtube Thumbnail Maker")
        }
        .defaultSize(width: 800, height: 500)
        .windowResizability(.contentSize)
    }
}
