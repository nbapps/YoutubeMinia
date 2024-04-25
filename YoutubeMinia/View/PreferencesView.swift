//
//  PreferencesView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI
import KeyboardShortcuts

struct PreferencesView: View {
    var body: some View {
        VStack {
            KeyboardShortcuts.Recorder(
                String(localized: "!Fetch thumbnail from clipboard:"),
                name: .fetchThumbnail
            )
            
            KeyboardShortcuts.Recorder(
                String(localized: "!Copy last thumbnail:"),
                name: .copyLastFetch
            )
        }
        .frame(width: 400)
        .frame(height: 550)
        .navigationTitle("!Preferences")
    }
}

#Preview {
    PreferencesView()
}
