//
//  CharacterSelectionViewModel.swift
//  AyoBaca
//

import SwiftUI
import Combine

struct CharacterInfo: Identifiable, Equatable {
    let id = UUID()
    let character: String
    var status: CharacterStatus
}

enum CharacterStatus: Equatable {
    case locked
    case unlocked
    case current 
}

@MainActor
class CharacterSelectionViewModel: ObservableObject {
    @Published var availableCharacters: [CharacterInfo] = []
    @Published var levelName: String
    @Published var currentLearningCharacterDisplay: String // For UI emphasis

    private let levelDefinition: LevelDefinition
    private var appStateManager: AppStateManager
    private var progressManager: CharacterProgressManager {
        appStateManager.characterProgress
    }
    private var cancellables = Set<AnyCancellable>()

    init(appStateManager: AppStateManager, levelDefinition: LevelDefinition) {
        self.appStateManager = appStateManager
        self.levelDefinition = levelDefinition
        self.levelName = levelDefinition.name
        self.currentLearningCharacterDisplay =
            appStateManager.currentLearningCharacter
            ?? appStateManager.characterProgress.getNextCharacterToLearn() // Ensure it has a value

        loadCharacterData() // Initial load

        // Subscribe to changes in the AppStateManager's currentLearningCharacter
        appStateManager.$currentLearningCharacter
            .receive(on: DispatchQueue.main) // Ensure UI updates on main thread
            .sink { [weak self] newLearningCharOptional in
                guard let self = self else { return }
                let newChar =
                    newLearningCharOptional
                    ?? self.appStateManager.characterProgress
                        .getNextCharacterToLearn()
                if self.currentLearningCharacterDisplay != newChar {
                    self.currentLearningCharacterDisplay = newChar
                    self.refreshCharacterStatuses() // Refresh statuses when it changes
                }
            }
            .store(in: &cancellables)

        // Also subscribe to changes in unlocked characters if they can change externally
        // For now, assuming changes are driven by currentLearningCharacter for status updates.
    }

    func onAppear() {
        self.currentLearningCharacterDisplay =
            appStateManager.currentLearningCharacter
            ?? appStateManager.characterProgress.getNextCharacterToLearn()
        loadCharacterData() // This internally calls refreshCharacterStatuses
    }

    private func loadCharacterData() {
        let characterRange = levelDefinition.range
        var chars: [CharacterInfo] = []

        // Ensure the range is valid for character iteration (e.g., "A"..."Z")
        if characterRange.lowerBound.count == 1
            && characterRange.upperBound.count == 1
            && characterRange.lowerBound <= characterRange.upperBound
            && characterRange.lowerBound.trimmingCharacters(in: .whitespaces)
                != ""
        {
            let lower = Character(characterRange.lowerBound)
            let upper = Character(characterRange.upperBound)
            if let lowerAscii = lower.asciiValue,
                let upperAscii = upper.asciiValue
            {
                for i in lowerAscii...upperAscii {
                    let charValue = UnicodeScalar(i)
                    let charString = String(charValue).uppercased()
                    // Status determined by refreshCharacterStatuses, set a default here
                    chars.append(
                        CharacterInfo(character: charString, status: .locked))
                }
            }
        } else {
            print(
                "Warning: CharacterSelection for placeholder or invalid level range \(levelDefinition.name) with range '\(characterRange)'"
            )
        }
        self.availableCharacters = chars
        refreshCharacterStatuses() // Apply correct statuses after loading
    }

    private func refreshCharacterStatuses() {
        let actualCurrentLearningChar =
            appStateManager.currentLearningCharacter
            ?? appStateManager.characterProgress.getNextCharacterToLearn()

        for i in availableCharacters.indices {
            let charString = availableCharacters[i].character
            let isUnlocked = progressManager.isCharacterUnlocked(charString)
            let isCurrent = (actualCurrentLearningChar == charString)

            if isCurrent {
                availableCharacters[i].status = .current
            } else if isUnlocked {
                availableCharacters[i].status = .unlocked
            } else {
                availableCharacters[i].status = .locked
            }
        }
        // Update the display variable if it's not directly bound to a characterInfo status
        self.currentLearningCharacterDisplay = actualCurrentLearningChar
    }

    func characterTapped(_ characterInfo: CharacterInfo) {
        guard characterInfo.status != .locked else {
            print("Character \(characterInfo.character) is locked.")
            // Optionally, provide user feedback (e.g., haptic, small message)
            return
        }
        print(
            "Character \(characterInfo.character) tapped. Status: \(characterInfo.status)"
        )

        // Set the tapped character as the one to start learning/practicing
        // This will also update currentLearningCharacterDisplay via the publisher
        appStateManager.setCurrentLearningCharacter(characterInfo.character)

        // Navigate to PronunciationHelper for the selected character
        appStateManager.navigateTo(.pronunciationHelper(
            character: characterInfo.character,
            levelDefinition: self.levelDefinition
        ))
    }

    func navigateBackToLevelMap() {
        // The withAnimation is handled by goBack or NavigationStack's default
        appStateManager.goBack()
    }
    
    
}
