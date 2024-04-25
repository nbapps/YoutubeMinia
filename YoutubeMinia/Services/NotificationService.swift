//
//  NotificationService.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation
import UserNotifications

final class NotificationService {
    func sendInstantNotification(urlStr: String, message: String) async throws {
        try await requestAutorizationIfNeeded()
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Youtube Minia Maker"
        content.subtitle = message
        content.body = urlStr
        content.interruptionLevel = .active
        content.sound = .default
        
        let identifier = UUID().uuidString
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        try await center.add(request)
    }
    
    func requestAutorizationIfNeeded() async throws {
        let center = UNUserNotificationCenter.current()
        
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
}
