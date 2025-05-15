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
            let backgroundColor =
                (appStateManager.currentScreen == .onboardingIntro1
                    || appStateManager.currentScreen == .onboardingIntro2)
                ? Color(red: 0.6, green: 0.8, blue: 1.0) // Specific blue for intro screens
                : Color("AppOrange") // Default orange for others

            backgroundColor.ignoresSafeArea()

            switch appStateManager.currentScreen {
            case .splash:
                SplashView(
                    viewModel: SplashViewModel(
                        appStateManager: appStateManager,
                        modelContext: modelContext))
                    .transition(.opacity)
            case .login:
                LoginView(
                    viewModel: LoginViewModel(
                        appStateManager: appStateManager))
                    .pageTransition()
            case .welcome:
                WelcomeView(
                    viewModel: WelcomeViewModel(
                        appStateManager: appStateManager))
                    .environmentObject(onboardingState)
                    .pageTransition()
            case .nameSetup:
                NameSetupView(
                    viewModel: NameSetupViewModel(
                        appStateManager: appStateManager,
                        onboardingState: onboardingState))
                    .environmentObject(onboardingState)
                    .pageTransition()
            case .ageSetup:
                AgeSetupView(
                    viewModel: AgeSetupViewModel(
                        appStateManager: appStateManager,
                        onboardingState: onboardingState,
                        modelContext: modelContext))
                    .environmentObject(onboardingState)
                    .pageTransition()
            case .onboardingIntro1:
                OnboardingIntro1View(
                    viewModel: OnboardingIntroViewModel(
                        appStateManager: appStateManager,
                        onboardingState: onboardingState))
                    .pageTransition()
            case .onboardingIntro2:
                OnboardingIntro2View(
                    viewModel: OnboardingIntroViewModel(
                        appStateManager: appStateManager,
                        onboardingState: onboardingState))
                    .pageTransition()
            case .mainApp:
                DashboardView(
                    viewModel: DashboardViewModel(
                        appStateManager: appStateManager,
                        modelContext: modelContext // Pass modelContext if DashboardViewModel needs it
                    ))
                    .transition(.move(edge: .trailing))
            case .profile:
                ProfileView(
                    viewModel: ProfileViewModel(
                        appStateManager: appStateManager,
                        modelContext: modelContext))
                    .transition(.move(edge: .trailing))
            case .levelMap:
                LevelMapView(
                    viewModel: LevelMapViewModel(
                        appStateManager: appStateManager))
                    .transition(.move(edge: .trailing))
            
            case let .characterSelection(levelDefinition):
                CharacterSelectionView(
                    viewModel: CharacterSelectionViewModel(
                        appStateManager: appStateManager,
                        levelDefinition: levelDefinition
                    )
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)))
            
            // MODIFIED: spellingActivity case now includes levelDefinition
            case let .spellingActivity(character, levelDefinition):
                SpellingView(
                    viewModel: SpellingViewModel(
                        appStateManager: appStateManager,
                        character: character,
                        levelDefinition: levelDefinition // Pass it to the ViewModel
                    )
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)))

            case let .writingActivity(character, levelDefinition):
                WritingView(
                    viewModel: WritingViewModel(
                        appStateManager: appStateManager,
                        character: character,
                        levelDefinition: levelDefinition
                    )
                )
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
