//
//  is.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

import SwiftUI

extension View {
    func pageTransition() -> some View {
        // Ensure PageTransition struct is accessible
        self.modifier(PageTransition())
    }
}
