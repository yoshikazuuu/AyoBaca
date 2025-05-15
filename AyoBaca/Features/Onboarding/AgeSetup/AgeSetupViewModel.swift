//
//  AgeSetupViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import Combine
import SwiftData // For ModelContext

@MainActor
class AgeSetupViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var animateTitle = false
    @Published var animateAgeSelector = false
    @Published var animateContinueButton = false
    @Published var animateMascotSpeechBubble = false
    @Published var showConfetti = false

    let ages = Array(1...15) // Age range

    // MARK: - Dependencies
    private var appStateManager: AppStateManager
    @ObservedObject var onboardingState: OnboardingState
    private var modelContext: ModelContext

    init(
        appStateManager: AppStateManager,
        onboardingState: OnboardingState,
        modelContext: ModelContext
    ) {
        self.appStateManager = appStateManager
        self.onboardingState = onboardingState
        self.modelContext = modelContext
    }

    // MARK: - View Lifecycle
    func viewDidAppear() {
        // Reset shared animation state for mascot for fresh animation
        onboardingState.animateMascot = false

        withAnimation(.easeOut(duration: 0.5)) {
            animateTitle = true
        }
        withAnimation(
            .spring(response: 0.6, dampingFraction: 0.7).delay(0.2)
        ) {
            animateAgeSelector = true
        }
        withAnimation(
            .spring(response: 0.7, dampingFraction: 0.6).delay(0.3)
        ) {
            // Trigger mascot image animation via shared OnboardingState
            onboardingState.animateMascot = true
            animateMascotSpeechBubble = true
        }

        // If age was already selected (e.g., user navigated back and forth)
        if onboardingState.childAge != nil {
            withAnimation {
                animateContinueButton = true
            }
        }
    }

    // MARK: - User Actions
    func selectAge(_ age: Int) {
        withAnimation(.spring(response: 0.4)) {
            onboardingState.childAge = age
            showConfetti = true // Trigger confetti
        }

        // Show continue button after selection
        withAnimation(
            .spring(response: 0.6, dampingFraction: 0.7).delay(0.3)
        ) {
            animateContinueButton = true
        }

        // Hide confetti after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showConfetti = false
            }
        }
    }

    func continueToNextStep() {
        guard let age = onboardingState.childAge, !onboardingState.childName.isEmpty else {
            print("Child name or age is missing.")
            // Optionally show an error to the user
            return
        }

        let newProfile = UserProfile(
            childName: onboardingState.childName,
            childAge: age,
            completedOnboarding: false
        )
        appStateManager.saveOnboardingProfile(with: newProfile, in: modelContext)

        // withAnimation is handled by navigateTo or NavigationStack's default
        appStateManager.navigateTo(.onboardingIntro1)
    }

    func navigateBack() {
        // withAnimation is handled by goBack or NavigationStack's default
        appStateManager.goBack()
    }
}
