//
//  PageTransition.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//


// ViewModifiers.swift
import SwiftUI

struct PageTransition: ViewModifier {
    func body(content: Content) -> some View {
        content
            .transition(
                .asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                )
            )
    }
}

extension View {
    func pageTransition() -> some View {
        self.modifier(PageTransition())
    }
}
