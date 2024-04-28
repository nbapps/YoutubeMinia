//
//  Date+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation

extension Date {
    func formatPublicationDate() -> String {
        let calendar = Calendar.current
        let now = Date.now
        let dateComponents = calendar.dateComponents([.day, .hour, .minute, .second], from: self, to: now)
        
        let diffSeconds = dateComponents.second ?? 0
        let diffMinutes = dateComponents.minute ?? 0
        let diffHours = dateComponents.hour ?? 0
        let diffDays = dateComponents.day ?? 0
        
        if diffMinutes < 1 && diffHours == 0 && diffDays == 0 {
            return String(localized: "!\(diffSeconds) second\(diffSeconds != 1 ? "s" : "") ago")
        }
        
        if diffHours < 1 && diffDays == 0 {
            return String(localized: "!\(diffMinutes) minute\(diffMinutes != 1 ? "s" : "") ago")
        }
        
        if diffDays < 1 {
            return String(localized: "!\(diffHours) hour\(diffHours != 1 ? "s" : "") ago")
        }
        
        if diffDays < 7 {
            return String(localized: "!\(diffDays) day\(diffDays != 1 ? "s" : "") ago")
        }
        
        if diffDays < 30 {
            let diffWeeks = diffDays / 7
            return String(localized: "!\(diffWeeks) week\(diffWeeks != 1 ? "s" : "") ago")
        }
        
        if diffDays < 365 {
            let diffMonths = diffDays / 30
            return String(localized: "!\(diffMonths) month\(diffMonths != 1 ? "s" : "") ago")
        }
        
        let diffYears = diffDays / 365
        return String(localized: "!\(diffYears) year\(diffYears != 1 ? "s" : "") ago")
    }
}
