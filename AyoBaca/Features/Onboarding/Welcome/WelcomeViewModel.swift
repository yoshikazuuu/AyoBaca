//
//  WelcomeViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import Combine

@MainActor
class WelcomeViewModel: ObservableObject {
    @Published var animateTitle = false
    @Published var animateText = false
    @Published var animateButton = false
    // animateMascot will be controlled by OnboardingState passed via EnvironmentObject to the View

    private var appStateManager: AppStateManager

    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
    }

    func onAppearActions(onboardingState: OnboardingState) {
        onboardingState.animateContent = false // Reset if coming back
        onboardingState.animateMascot = false

        withAnimation(.easeOut(duration: 0.7)) {
            animateTitle = true
        }
        withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
            animateText = true
        }
        withAnimation(
            .spring(response: 0.6, dampingFraction: 0.6).delay(0.5)
        ) {
            animateButton = true
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            onboardingState.animateMascot = true // Control mascot via shared state
        }
    }

    func continueToProfileSetup() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            appStateManager.currentScreen = .nameSetup
        }
    }
}
