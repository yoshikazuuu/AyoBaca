//
//  Font+AppFont.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

import SwiftUI

extension Font {
    static func appFont(_ type: FontType, size: CGFloat) -> Font {
        return .custom(type.rawValue, size: size)
    }
    
    // Navigation and level-specific dyslexic fonts with optimized spacing
    static func navigationFont(size: CGFloat, isBold: Bool = true) -> Font {
        return .custom(
            isBold ? FontType.dylexicBold.rawValue : FontType.dylexicRegular.rawValue, 
            size: size, 
            relativeTo: .body
        )
    }
    
    static func levelFont(size: CGFloat, isBold: Bool = false) -> Font {
        return .custom(
            isBold ? FontType.dylexicBold.rawValue : FontType.dylexicRegular.rawValue, 
            size: size, 
            relativeTo: .body
        )
    }
    
    // Example usage inside the View:
    // .font(.appFont(.dylexicBold, size: 60))
    // .font(.navigationFont(size: 18))
    // .font(.levelFont(size: 16, isBold: true))
}

// Extension to provide view modifier for dyslexic-friendly text styling
extension View {
    func dyslexicTextStyle(size: CGFloat, isBold: Bool = false, isNavigation: Bool = false) -> some View {
        return self
            .font(.custom(
                isBold ? FontType.dylexicBold.rawValue : FontType.dylexicRegular.rawValue,
                size: size
            ))
            .tracking(0.5) // Increased letter spacing
            .lineSpacing(8) // Increased line spacing
    }
    
    func navigationStyle(size: CGFloat = 16) -> some View {
        return self
            .font(.navigationFont(size: size))
            .tracking(0.5) // Increased letter spacing
            .lineSpacing(6) // Increased line spacing for navigation elements
    }
    
    func levelStyle(size: CGFloat = 18, isBold: Bool = false) -> some View {
        return self
            .font(.levelFont(size: size, isBold: isBold))
            .tracking(0.6) // More increased letter spacing for level text
            .lineSpacing(8) // Increased line spacing
    }
}
