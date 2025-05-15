//
//  DashboardViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import Combine
import SwiftData
import TipKit

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var childName: String = "Anak"
    @Published var childAge: Int = 0
    @Published var currentStreak: Int = 0
    @Published var currentLearningCharacter: String? = nil
    
    @Published var mainTips = TipGroup(.ordered) {
        ProfileTip()
        MascotAndStreakTip()
        PracticeButtonTip()
        MapButtonTip()
        ProfileButtonTip()
    }
    
    private var appStateManager: AppStateManager // Already a dependency
    private var cancellables = Set<AnyCancellable>()
    
    init(appStateManager: AppStateManager, modelContext: ModelContext? = nil) {
        self.appStateManager = appStateManager
        
        appStateManager.$userProfile
            .compactMap { $0 }
            .sink { [weak self] profile in
                self?.childName = profile.childName
                self?.childAge = profile.childAge
            }
            .store(in: &cancellables)
        
        appStateManager.$currentStreak
            .sink { [weak self] streak in
                self?.currentStreak = streak
            }
            .store(in: &cancellables)
        
        appStateManager.$currentLearningCharacter
            .sink { [weak self] character in
                self?.currentLearningCharacter = character
            }
            .store(in: &cancellables)
        
        self.childName = appStateManager.userProfile?.childName ?? "Anak"
        self.childAge = appStateManager.userProfile?.childAge ?? 0
        self.currentStreak = appStateManager.currentStreak
        self.currentLearningCharacter = appStateManager.currentLearningCharacter
    }
    
    func startPracticeTapped() {
        if let character = currentLearningCharacter, !character.isEmpty, character != "Z" {
            print("Resuming practice for character: \(character)")
            if "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(character) {
                // MODIFIED: Pass the mainAlphabetLevelDefinition from AppStateManager
                appStateManager.currentScreen = .spellingActivity(
                    character: character,
                    levelDefinition: appStateManager.mainAlphabetLevelDefinition // Use the definition from AppStateManager
                )
            } else {
                print("Invalid currentLearningCharacter '\(character)', going to map.")
                appStateManager.currentScreen = .levelMap
            }
        } else {
            let nextCharToLearn = appStateManager.characterProgress.getNextCharacterToLearn()
            print("No current character set or Z completed. Next to learn: \(nextCharToLearn). Navigating to Level Map.")
            appStateManager.currentScreen = .levelMap
        }
    }
    
    func mapButtonTapped() {
        appStateManager.currentScreen = .levelMap
    }
    
    func profileButtonTapped() {
        appStateManager.currentScreen = .profile
    }
}
