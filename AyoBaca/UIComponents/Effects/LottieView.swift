//
//  LottieView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

import SwiftUI

// For Lottie animations, you'll need to add the package and create a wrapper:
struct LottieView: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        // Add Lottie animation here - requires Lottie package
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Update the view
    }
}
