//
//  ProfileViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import Combine
import SwiftData

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var childName: String = "Anak"
    @Published var childAge: Int = 0
    @Published var appVersion: String = "1.0.0"

    @Published var showOnboardingResetAlert = false
    @Published var showProgressResetAlert = false
    @Published var showUserDataResetAlert = false

    private var appStateManager: AppStateManager
    private var modelContext: ModelContext

    private var cancellables = Set<AnyCancellable>()

    init(appStateManager: AppStateManager, modelContext: ModelContext) {
        self.appStateManager = appStateManager
        self.modelContext = modelContext

        appStateManager.$userProfile
            .compactMap { $0 }
            .sink { [weak self] profile in
                self?.childName = profile.childName
                self?.childAge = profile.childAge
            }
            .store(in: &cancellables)
        
        self.childName = appStateManager.userProfile?.childName ?? "Anak"
        self.childAge = appStateManager.userProfile?.childAge ?? 0
        
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
           let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            self.appVersion = "Versi \(version) (\(build))"
        }
    }

    func navigateBackToDashboard() {
        appStateManager.currentScreen = .mainApp
    }

    func notificationsTapped() { print("Notifications settings tapped") }
    func soundSettingsTapped() { print("Sound settings tapped") }
    func fontSizeTapped() { print("Font size settings tapped") }
    func termsTapped() { print("Terms of Use tapped") }
    func privacyPolicyTapped() { print("Privacy Policy tapped") }

    func confirmResetOnboarding() { showOnboardingResetAlert = true }
    func confirmResetCharacterProgress() { showProgressResetAlert = true }
    func confirmClearAllUserData() { showUserDataResetAlert = true }

    func performResetOnboarding() {
        // MODIFIED: Pass modelContext to resetOnboarding
        appStateManager.resetOnboarding(in: modelContext)
    }

    func performResetCharacterProgress() {
        appStateManager.characterProgress.resetProgress()
        if appStateManager.currentLearningCharacter != "A" && appStateManager.characterProgress.isCharacterUnlocked("A") {
             appStateManager.setCurrentLearningCharacter(appStateManager.characterProgress.getNextCharacterToLearn())
        }
    }

    func performClearAllUserData() {
        // This function already handles its own data deletion using modelContext.
        // It then calls appStateManager.resetOnboarding, which will now also use the context
        // passed from here (indirectly, as resetOnboarding is now self-contained with its context param).
        // The key is that ProfileViewModel's modelContext is the one used.
        Task {
            do {
                try modelContext.delete(model: UserProfile.self)
                try modelContext.delete(model: ReadingActivity.self)
                try modelContext.save()
                
                print("All user data cleared successfully from ProfileViewModel.")
                
                // This will now correctly use the modelContext passed to it.
                appStateManager.resetOnboarding(in: modelContext)

            } catch {
                print("Error clearing user data from ProfileViewModel: \(error)")
            }
        }
    }
}
