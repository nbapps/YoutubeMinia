//
//  YoutubeMiniaApp.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 24/04/2024.
//

import SwiftUI
import SwiftData
import UserNotifications

enum Tabs {
    case maker, last
}

@main
struct YoutubeMiniaApp: App {
#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#else
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    
    @StateObject private var thumbnailMakerViewModel = ThumbnailMakerViewModel.shared
    
    var body: some Scene {
#if os(macOS)
        Window("!Youtube Minia Maker", id: WindowId.main.rawValue) {
            ContentView()
                .dataContainer()
                .environmentObject(thumbnailMakerViewModel)
                .frame(minWidth: 700, minHeight: 400)
                .navigationTitle("!Youtube Minia Maker")
        }
        .defaultSize(width: 850, height: 600)
        .windowResizability(.contentSize)
        .commands {
            SidebarCommands()
        }
        
        Settings {
            NavigationStack {
                PreferencesView()
            }
            .environmentObject(thumbnailMakerViewModel)
        }
        .windowResizability(.contentSize)
        
        MenuBarExtra("!Youtube Minia Maker", systemImage: "photo.badge.arrow.down") {
            MenuBarExtraView()
                .environmentObject(thumbnailMakerViewModel)
        }
        .menuBarExtraStyle(.menu)
#else
        
        WindowGroup {
            TabView(selection: $thumbnailMakerViewModel.selectedTab) {
                ContentView()
                    .tabItem { Label("Maker", systemImage: "photo") }
                    .tag(Tabs.maker)
                
                LastUrlsListView()
                    .tabItem { Label("Last", systemImage: "externaldrive.fill.badge.icloud") }
                    .tag(Tabs.last)
            }
            .dataContainer()
            .environmentObject(thumbnailMakerViewModel)
        }
#endif
    }
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler(.banner)
        
    }
}
#else
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler(.banner)
        
    }
}
#endif
