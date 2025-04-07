//
//  ContentView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    // Global state manager
    @StateObject private var appStateManager = AppStateManager()
    // For onboarding screens
    @StateObject private var onboardingState = OnboardingState()
    // Access to SwiftData
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Color("AppOrange").ignoresSafeArea()

            switch appStateManager.currentScreen {
            case .splash:
                SplashView()
                    .environmentObject(appStateManager)
                    .transition(.opacity)
                    .onAppear {
                        // Check onboarding status when splash appears
                        Task { @MainActor in
                            appStateManager.checkOnboardingStatus(
                                in: modelContext)
                        }
                    }

            case .login:
                LoginView()
                    .environmentObject(appStateManager)
                    .environmentObject(onboardingState)
                    .pageTransition()

            case .welcome:
                WelcomeView()
                    .environmentObject(appStateManager)
                    .environmentObject(onboardingState)
                    .pageTransition()

            case .nameSetup:
                NameSetupView()
                    .environmentObject(appStateManager)
                    .environmentObject(onboardingState)
                    .pageTransition()

            case .ageSetup:
                AgeSetupView()
                    .environmentObject(appStateManager)
                    .environmentObject(onboardingState)
                    .pageTransition()

            case .mainApp:
                MainAppView()
                    .environmentObject(appStateManager)
                    .transition(.move(edge: .trailing))

            case .profile:
                ProfileView()
                    .environmentObject(appStateManager)
                    .transition(.move(edge: .trailing))

            case .levelMap:
                LevelMapView()
                    .environmentObject(appStateManager)
                    .transition(.move(edge: .trailing))  // Or your preferred transition

            // --- Add Learning Activity Cases ---
            case let .characterSelection(levelId):  // Use 'let' to extract associated value
                CharacterSelectionView(levelId: levelId)
                    .environmentObject(appStateManager)
                    // Choose appropriate transitions
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))

            case let .spellingActivity(character):
                SpellingView(character: character)
                    .environmentObject(appStateManager)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))

            case let .writingActivity(character):
                WritingView(character: character)
                    .environmentObject(appStateManager)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))

            }
        }
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8),
            value: appStateManager.currentScreen)
    }
}

#Preview {
    @MainActor in
    MainAppView()
        .environmentObject(AppStateManager())
        .modelContainer(AppModelContainer.preview)
}
