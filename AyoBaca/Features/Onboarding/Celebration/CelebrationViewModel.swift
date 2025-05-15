//
//  CelebrationViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI
import Combine

@MainActor
class CelebrationViewModel: ObservableObject {
    private var appStateManager: AppStateManager
    // OnboardingState to get the child's name for display
    @ObservedObject var onboardingState: OnboardingState

    var childNameDisplay: String {
        onboardingState.childName.isEmpty ? "Siswa" : onboardingState.childName
    }

    init(appStateManager: AppStateManager, onboardingState: OnboardingState) {
        self.appStateManager = appStateManager
        self.onboardingState = onboardingState
    }

    func viewDidAppear() {
        // Auto advance after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.navigateToMainApp()
        }
    }

    func navigateToMainApp() {
        // This assumes that by the time CelebrationView is shown,
        // the UserProfile is already created and onboarding is effectively complete.
        // AppStateManager's finalizeOnboarding might be called earlier,
        // or this could be the point it's called.
        // For simplicity, let's assume it's just a navigation.
        // If UserProfile creation and `finalizeOnboarding` happens here,
        // the ModelContext would also be needed.
        
        // If this is the *final* step of onboarding:
        // appStateManager.finalizeOnboardingAndNavigate()
        // else, if it's an intermediate celebration:
        withAnimation {
            appStateManager.currentScreen = .mainApp
        }
    }
}