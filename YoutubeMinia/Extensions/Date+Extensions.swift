//
//  Date+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation

extension Date {
    func formatPublicationDate() -> String {
        let diffDays = Calendar.current.dateComponents([.day], from: self, to: .now).day ?? 0
        
        if diffDays < 1 {
            let diffHours = Calendar.current.dateComponents([.hour], from: self, to: .now).hour ?? 0
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
