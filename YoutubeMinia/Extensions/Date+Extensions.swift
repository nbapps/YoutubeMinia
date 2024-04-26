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
        
        if diffDays < 7 {
            return String(localized: "!Since \(diffDays) day\(diffDays != 1 ? "s" : "")")
        }
        
        if diffDays < 30 {
            let diffWeeks = diffDays / 7
            return String(localized: "!Since \(diffWeeks) week\(diffWeeks != 1 ? "s" : "")")
        }
        
        if diffDays < 365 {
            let diffMonths = diffDays / 30
            return String(localized: "!Since \(diffMonths) month\(diffMonths != 1 ? "s" : "")")
        }
        
        let diffYears = diffDays / 365
        return String(localized: "!Since \(diffYears) year\(diffYears != 1 ? "s" : "")")
    }
}
