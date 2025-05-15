//
//  NameSetupViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import Combine

@MainActor
class NameSetupViewModel: ObservableObject {
    // MARK: - Published Properties for UI State
    @Published var animateTitle = false
    @Published var animateTextField = false
    @Published var animateButton = false
    @Published var animateMascotSpeechBubble = false

    // MARK: - Dependencies
    private var appStateManager: AppStateManager
    @ObservedObject var onboardingState: OnboardingState

    init(appStateManager: AppStateManager, onboardingState: OnboardingState) {
        self.appStateManager = appStateManager
        self.onboardingState = onboardingState
    }

    // MARK: - View Lifecycle Actions
    func viewDidAppear() {
        // Reset shared animation state for mascot for fresh animation
        // This allows the animation to replay if the user navigates back and then forward here.
        onboardingState.animateMascot = false

        // Sequence the animations
        withAnimation(.easeOut(duration: 0.5)) {
            animateTitle = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            animateTextField = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            animateButton = true
        }
        // Animate speech bubble and trigger the shared mascot animation
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.4)) {
            animateMascotSpeechBubble = true
            onboardingState.animateMascot = true
        }
    }

    // MARK: - User Actions
    func navigateBack() {
        // withAnimation is handled by goBack or NavigationStack's default
        appStateManager.goBack()
    }

    func continueToAgeSetup() {
        guard !onboardingState.childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Child's name cannot be empty.")
            return
        }
        // withAnimation is handled by navigateTo or NavigationStack's default
        appStateManager.navigateTo(.ageSetup)
    }
}
