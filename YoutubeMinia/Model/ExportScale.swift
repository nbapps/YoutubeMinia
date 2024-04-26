//
//  ExportScale.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 26/04/2024.
//

import Foundation

enum ExportScale: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case x1, x2, x3
    
    var scale: CGFloat {
        switch
        self {
        case .x1: 1
        case .x2: 2
        case .x3: 3
        }
    }
}
