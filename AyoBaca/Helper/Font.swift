//
//  Font.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//

import SwiftUI

enum FontType: String {
    case rethinkRegular = "RethinkSans-Regular"
    case rethinkBold = "RethinkSans-Regular_Bold"
    case rethinkExtraBold = "RethinkSans-Regular_ExtraBold"
    case rethinkItalic = "RethinkSans-Italic"
    case dylexicRegular = "OpenDyslexic-Regular"
    case dylexicBold = "OpenDyslexic-Bold"
    case dylexicItalic = "OpenDyslexic-Italic"
}

extension Font {
    static func appFont(_ type: FontType, size: CGFloat) -> Font {
        return .custom(type.rawValue, size: size)
    }

    // Example usage inside the View:
    // .font(.appFont(.dylexicBold, size: 60))
}
