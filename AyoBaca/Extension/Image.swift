//
//  Image.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//

import SwiftUI

// Helper to get UIImage size
extension Image {
    var size: CGSize {
        guard let uiImage = UIImage(named: "mascot-hi") else {
            print("Warning: Could not load image 'mascot-hi' to get size.")
            return CGSize(width: 1, height: 1)
        }
        guard uiImage.size.width > 0, uiImage.size.height > 0 else {
            print("Warning: Image 'mascot-hi' has zero width or height.")
            return CGSize(width: 1, height: 1)
        }
        return uiImage.size
    }
}
