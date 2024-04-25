//
//  PreferencesView.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import SwiftUI
import KeyboardShortcuts
import ServiceManagement

struct PreferencesView: View {
    @State private var startAppWithSession = SMAppService.mainApp.status == .enabled ? true : false
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Image("yttm_icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                    
                    VStack(alignment: .leading) {
                        Text("!Youtube minia")
                            .font(.largeTitle)
                        
                        Text("!Get stylish YouTube thumbnails")
                            .foregroundStyle(.secondary)
                        
                        Text(verbatim: "\(Bundle.main.appVersion) - \(Bundle.main.buildNumber)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                    .padding()
                
                VStack(alignment: .trailing) {
                    Text("!Preferences")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle(
                        "!Start with session",
                        isOn: $startAppWithSession
                    )
                    
                    KeyboardShortcuts.Recorder(
                        String(localized: "!Fetch thumbnail from clipboard:"),
                        name: .fetchThumbnail
                    )
                    
                    KeyboardShortcuts.Recorder(
                        String(localized: "!Copy last thumbnail:"),
                        name: .copyLastFetch
                    )
                }
                
                Divider()
                    .padding()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("!Context")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("!This app was created following Basti Ui and Benjamin Code's network challenge. This app is open source. The Github link is below.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("!Thanks to this app, you can create a thumbnail of an already published YouTube video for use in your montages or for sharing on the networks. Works with long videos and shorts.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("!You can share a configuration file with your editor so that he can use exactly the same configuration as you had created.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("!To create a thumbnail, you can either copy and paste the Youtube url into the app, or drag and drop it into the app, or configure a keyboard shortcut to automatically generate the thumbnail after copying the URL.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("!You can then share the image by saving it in the download folder, copying it to the clipboard or directly dragging and dropping it into your editing or graphics software.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Link("@BenjaminCode", destination: URL(string: "https://www.youtube.com/@BenjaminCode/videos")!)
                    Link("@BastiUi", destination: URL(string: "https://www.youtube.com/@BastiUi/videos")!)
                    Link("!Source code", destination: URL(string: "https://github.com/nbapps/YoutubeMinia")!)
                    Link("!Our other apps", destination: URL(string: "https://nbapps.fr")!)
                }
            }
            .padding()
        }
            .frame(width: 400)
            .frame(height: 550)
            .navigationTitle("!Preferences")
    }
}

#Preview {
    PreferencesView()
}
