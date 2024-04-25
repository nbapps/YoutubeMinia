//
//  Font+Extensions.swift
//  YoutubeMinia
//
//  Created by Nicolas Bachur on 25/04/2024.
//

import Foundation
import SwiftUI

extension Font {
    static func roboto(weight: Font.Weight = .regular, size: CGFloat) -> Font {
        switch weight {
        case .black: Font.custom("Roboto-Black", size: size)
        case .bold: Font.custom("Roboto-Bold", size: size)
        case .medium: Font.custom("Roboto-Medium", size: size)
        case .regular: Font.custom("Roboto-Regular", size: size)
        case .light: Font.custom("Roboto-Light", size: size)
        case .thin: Font.custom("Roboto-Thin", size: size)
        default: Font.custom("Roboto-Regular", size: size)
        }
    }
}
