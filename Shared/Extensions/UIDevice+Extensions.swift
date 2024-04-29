//
//  UIDevice+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 29/04/2024.
//

#if !os(macOS)
import UIKit

extension UIDevice {
    var isPad: Bool {
        userInterfaceIdiom == .pad 
    }
}
#endif
