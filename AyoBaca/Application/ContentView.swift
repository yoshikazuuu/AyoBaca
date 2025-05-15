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
        NavigationStack(path: navigationPathBinding) {
            Color.clear
                .navigationDestination(for: AppScreen.self) { screen in
                    destinationView(for: screen)
                        .navigationBarBackButtonHidden(true)
                }
        }
    }
    
    // Create a binding for the NavigationStack that respects navigationPath's private(set)
    private var navigationPathBinding: Binding<[AppScreen]> {
        Binding(
            get: { appStateManager.navigationPath },
            set: { _ in } // No-op setter since we use appStateManager's navigation methods
        )
    }

    @ViewBuilder
    private func destinationView(for screen: AppScreen) -> some View {
        switch screen {
        case .splash:
            SplashView(
                viewModel: SplashViewModel(
                    appStateManager: appStateManager,
                    modelContext: modelContext))
        case .login:
            LoginView(
                viewModel: LoginViewModel(
                    appStateManager: appStateManager))
        case .welcome:
            WelcomeView(
                viewModel: WelcomeViewModel(
                    appStateManager: appStateManager))
                .environmentObject(onboardingState)
        case .nameSetup:
            NameSetupView(
                viewModel: NameSetupViewModel(
                    appStateManager: appStateManager,
                    onboardingState: onboardingState))
                .environmentObject(onboardingState)
        case .ageSetup:
            AgeSetupView(
                viewModel: AgeSetupViewModel(
                    appStateManager: appStateManager,
                    onboardingState: onboardingState,
                    modelContext: modelContext))
                .environmentObject(onboardingState)
        case .onboardingIntro1:
            OnboardingIntro1View(
                viewModel: OnboardingIntroViewModel(
                    appStateManager: appStateManager,
                    onboardingState: onboardingState))
        case .onboardingIntro2:
            OnboardingIntro2View(
                viewModel: OnboardingIntroViewModel(
                    appStateManager: appStateManager,
                    onboardingState: onboardingState))
        case .mainApp:
            DashboardView(
                viewModel: DashboardViewModel(
                    appStateManager: appStateManager,
                    modelContext: modelContext
                ))
        case .profile:
            ProfileView(
                viewModel: ProfileViewModel(
                    appStateManager: appStateManager,
                    modelContext: modelContext))
        case .levelMap:
            LevelMapView(
                viewModel: LevelMapViewModel(
                    appStateManager: appStateManager))
        
        case let .characterSelection(levelDefinition):
            CharacterSelectionView(
                viewModel: CharacterSelectionViewModel(
                    appStateManager: appStateManager,
                    levelDefinition: levelDefinition
                )
            )
        
        case let .spellingActivity(character, levelDefinition):
            SpellingView(
                viewModel: SpellingViewModel(
                    appStateManager: appStateManager,
                    character: character,
                    levelDefinition: levelDefinition
                )
            )

        case let .writingActivity(character, levelDefinition):
            WritingView(
                viewModel: WritingViewModel(
                    appStateManager: appStateManager,
                    character: character,
                    levelDefinition: levelDefinition
                )
            )
        }
    }
}
