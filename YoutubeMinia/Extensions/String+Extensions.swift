//
//  String+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation

extension String {
    func formatFileName() -> String {
        let cleanedString = replacingOccurrences(of: "[^a-zA-Z0-9]+", with: "_", options: .regularExpression, range: nil)
        
        let stringWithUnderscores = cleanedString.replacingOccurrences(of: " ", with: "_")
        
        return stringWithUnderscores
    }
    
    func formatViewCount() -> String {
        guard let number = Double(self) else {
            return String(localized: "!Invalid Number")
        }
        
        if number >= 1000 && number < 1000000 {
            let roundedNumber = round(number / 1000)
            return String(localized: "!\(Int(roundedNumber)) k views")
        } else if number >= 1000000 {
            let roundedNumber = round(number / 1000000)
            return String(localized: "!\(Int(roundedNumber)) m views")
        } else {
            return String(localized: "!\(Int(number)) views")
        }
    }
    
    func formatChannelCount() -> String {
        guard let number = Double(self) else {
            return String(localized: "!Invalid Number")
        }
        
        if number >= 1000 && number < 1000000 {
            let roundedNumber = round(number / 1000)
            return String(localized: "!\(Int(roundedNumber)) k subscribers")
        } else if number >= 1000000 {
            let roundedNumber = round(number / 1000000)
            return String(localized: "!\(Int(roundedNumber)) m subscribers")
        } else {
            return String(localized: "!\(Int(number)) subscribers")
        }
    }
}
