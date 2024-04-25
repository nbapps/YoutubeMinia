//
//  NotificationService.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation
import UserNotifications

final class NotificationService {
    func sendInstatNotification(body: String) async throws {
        try await requestAutorizationIfNeeded()
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Youtube minia"
        content.body = body

        let identifier = UUID().uuidString
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        // Ajouter la demande de notification au centre de notification
        try await center.add(request)
    }
    
    func requestAutorizationIfNeeded() async throws {
        let center = UNUserNotificationCenter.current()
        
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
}
