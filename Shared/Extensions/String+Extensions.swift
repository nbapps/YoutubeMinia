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

        let value = number.formatted(.number.notation(.compactName))
        return String(localized: "!\(value.lowercased()) views")
    }
    
    func formatChannelCount() -> String {
        guard let number = Double(self) else {
            return String(localized: "!Invalid Number")
        }
        
        let value = number.formatted(.number.notation(.compactName))
        return String(localized: "!\(value.lowercased()) subscribers")
    }
    
    func formattedVideoDuration() -> String {
        let formattedDuration = self
            .replacingOccurrences(of: "PT", with: "")
            .replacingOccurrences(of: "H", with:":")
            .replacingOccurrences(of: "M", with: ":")
            .replacingOccurrences(of: "S", with: "")
        
        var components = formattedDuration.components(separatedBy: ":")
        
        if components.count == 1 {
            components.insert("00", at: 0)
        }
        
        var duration = ""
        for (index, component) in components.enumerated() {
            // Si le composant est vide, remplacez-le par "00"
            if component.isEmpty {
                duration += "00"
            } else {
                // Si le composant n'a qu'un chiffre, ajoutez "0" avant
                if component.count == 1 {
                    duration += "0" + component
                } else {
                    duration += component
                }
            }
            
            if index < components.count - 1 {
                duration += ":"
            }
        }
        
        return duration
    }
}
