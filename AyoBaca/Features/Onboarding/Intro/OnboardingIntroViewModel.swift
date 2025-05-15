//
//  OnboardingIntroViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI
import Combine

@MainActor
class OnboardingIntroViewModel: ObservableObject {
    // MARK: - Published Properties for UI State
    @Published var animateBubble = false
    @Published var animateMascot = false // For mascot appearance in these specific intros
    @Published var animateButton = false // Specifically for the button in Intro2

    // MARK: - Dependencies
    private var appStateManager: AppStateManager
    // OnboardingState might be used if there are shared animation states for the mascot
    // across multiple onboarding views, or if other temporary onboarding data is needed.
    // For now, childName comes from appStateManager.userProfile.
    private var onboardingState: OnboardingState

    // MARK: - Computed Properties
    var childName: String {
        // Provide a fallback if the user profile isn't available for some reason
        appStateManager.userProfile?.childName ?? "Siswa"
    }

    init(appStateManager: AppStateManager, onboardingState: OnboardingState) {
        self.appStateManager = appStateManager
        self.onboardingState = onboardingState
    }

    // MARK: - View Lifecycle Actions
    func onAppearIntro1() {
        // Reset animation states if re-entering
        resetAnimationStates()
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2)) {
            animateBubble = true
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4)) {
            animateMascot = true // Trigger mascot for Intro1
        }
    }

    func onAppearIntro2() {
        resetAnimationStates()
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2)) {
            animateBubble = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
            animateButton = true // Trigger button for Intro2
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4)) {
            animateMascot = true // Trigger mascot for Intro2
        }
    }
    
    private func resetAnimationStates() {
        animateBubble = false
        animateMascot = false
        animateButton = false
    }

    // MARK: - User Actions / Navigation
    func navigateToOnboardingIntro2() {
        // withAnimation is handled by navigateTo or NavigationStack's default
        appStateManager.navigateTo(.onboardingIntro2)
    }

    func finalizeOnboardingAndNavigateToMainApp() {
        // AppStateManager handles the logic of setting character to 'A', etc.
        // and then sets appStateManager.currentScreen, which will reset the path.
        appStateManager.finalizeOnboarding()
    }
}
