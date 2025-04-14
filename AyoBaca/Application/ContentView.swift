//
//  ContentView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @StateObject private var appStateManager = AppStateManager()
    @StateObject private var onboardingState = OnboardingState()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            // Use the light blue for onboarding intro screens, orange otherwise
            let backgroundColor =
                (appStateManager.currentScreen == .onboardingIntro1
                    || appStateManager.currentScreen == .onboardingIntro2)
                ? Color(red: 0.6, green: 0.8, blue: 1.0)
                : Color("AppOrange")

            backgroundColor.ignoresSafeArea()

            switch appStateManager.currentScreen {
            case .splash:
                SplashView()
                    .environmentObject(appStateManager)
                    .transition(.opacity)
                    .onAppear {
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

            case .onboardingIntro1:
                OnboardingIntro1View()
                    .environmentObject(appStateManager)
                    .environmentObject(onboardingState)
                    .pageTransition()

            case .onboardingIntro2:
                OnboardingIntro2View()
                    .environmentObject(appStateManager)
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
                    .transition(.move(edge: .trailing))

            case let .characterSelection(levelId):
                CharacterSelectionView(levelId: levelId)
                    .environmentObject(appStateManager)
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
