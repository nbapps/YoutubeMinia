//
//  MenuBarExtraView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI

struct MenuBarExtraView: View {
    @EnvironmentObject private var viewModel: ThumbnailMakerViewModel
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        VStack {
            Text(viewModel.videoURlStr)
            
            SaveInDownloadButton(showError: .constant(false), errorMessage: .constant(""))
            CopyImageButtonView(showError: .constant(false), errorMessage: .constant(""))
            
            Divider()
            
            Button("!Open app") {
                openWindow(id: WindowId.main.rawValue)
            }
            .keyboardShortcut("0")
            
            SettingsLink {
                Text("!Open preferences")
            }
            .keyboardShortcut("p")
            
            Divider()
            Button("!Quit", role: .destructive) {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }

}

#Preview {
    MenuBarExtraView()
        .environmentObject(ThumbnailMakerViewModel.preview)
}
