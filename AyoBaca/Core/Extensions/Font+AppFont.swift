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

    // Example usage inside the View:
    // .font(.appFont(.dylexicBold, size: 60))
}
