//
//  OnboardingProgressView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//

import SwiftUI

struct OnboardingProgressView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(
                        step < currentStep ? Color.white : Color.white
                            .opacity(0.3)
                    )
                    .frame(width: 10, height: 10)
                    .scaleEffect(step == currentStep - 1 ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: currentStep)
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            }
        }
        .padding(.vertical, 20)
    }
}
