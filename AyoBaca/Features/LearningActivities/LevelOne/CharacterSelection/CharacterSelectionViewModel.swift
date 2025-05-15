//
//  CharacterSelectionViewModel.swift
//  AyoBaca
//

import SwiftUI
import Combine

// Helper structs CharacterInfo, CharacterStatus remain the same...
// ... (previous code for CharacterInfo and CharacterStatus) ...
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
    @Published var currentLearningCharacterDisplay: String

    private let levelDefinition: LevelDefinition // This is the key
    private var appStateManager: AppStateManager
    private var progressManager: CharacterProgressManager {
        appStateManager.characterProgress
    }
    private var cancellables = Set<AnyCancellable>()

    init(appStateManager: AppStateManager, levelDefinition: LevelDefinition) {
        self.appStateManager = appStateManager
        self.levelDefinition = levelDefinition
        self.levelName = levelDefinition.name
        self.currentLearningCharacterDisplay = appStateManager.currentLearningCharacter ?? "A"
        loadCharacterData()

        appStateManager.$currentLearningCharacter
            .sink { [weak self] newLearningCharOptional in
                self?.currentLearningCharacterDisplay = newLearningCharOptional ?? "A"
                self?.refreshCharacterStatuses()
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        self.currentLearningCharacterDisplay = appStateManager.currentLearningCharacter ?? "A"
        loadCharacterData()
    }

    private func loadCharacterData() {
        let characterRange = levelDefinition.range
        var chars: [CharacterInfo] = []

        if characterRange.lowerBound.count == 1 && characterRange.upperBound.count == 1 &&
           characterRange.lowerBound <= characterRange.upperBound &&
           characterRange.lowerBound != " " {
            let lower = Character(characterRange.lowerBound)
            let upper = Character(characterRange.upperBound)
            if let lowerAscii = lower.asciiValue, let upperAscii = upper.asciiValue {
                for i in lowerAscii...upperAscii {
                    let charValue = UnicodeScalar(i)
                    let charString = String(charValue).uppercased()
                    let currentActualLearningChar = appStateManager.currentLearningCharacter ?? "A"
                    let isUnlocked = progressManager.isCharacterUnlocked(charString)
                    let isCurrentLearning = (currentActualLearningChar == charString)
                    let status: CharacterStatus = isCurrentLearning ? .current : (isUnlocked ? .unlocked : .locked)
                    chars.append(CharacterInfo(character: charString, status: status))
                }
            }
        } else {
             print("Warning: CharacterSelection for placeholder or invalid level range \(levelDefinition.name)")
        }
        self.availableCharacters = chars
    }
    
    private func refreshCharacterStatuses() {
        let currentActualLearningChar = appStateManager.currentLearningCharacter ?? "A"
        for i in availableCharacters.indices {
            let charString = availableCharacters[i].character
            let isUnlocked = progressManager.isCharacterUnlocked(charString)
            let isCurrentLearning = (currentActualLearningChar == charString)
            if isCurrentLearning {
                availableCharacters[i].status = .current
            } else if isUnlocked {
                availableCharacters[i].status = .unlocked
            } else {
                availableCharacters[i].status = .locked
            }
        }
    }

    func characterTapped(_ characterInfo: CharacterInfo) {
        guard characterInfo.status != .locked else {
            print("Character \(characterInfo.character) is locked.")
            return
        }
        print("Character \(characterInfo.character) tapped. Status: \(characterInfo.status)")
        appStateManager.setCurrentLearningCharacter(characterInfo.character)

        // Example: Offer choices or go to a default activity.
        // For now, let's assume we might want to go to Writing or Spelling.
        // We'll make navigateToWritingActivity public for this example.
        navigateToWritingActivity(for: characterInfo.character)
    }

    func navigateToSpellingActivity(for character: String) {
        withAnimation(.easeInOut) {
            // If SpellingActivity also needs levelDefinition, update AppScreen and pass it here.
            appStateManager.currentScreen = 
                .spellingActivity(
                    character: character,
                    levelDefinition: levelDefinition
                )
        }
    }
    
    // MODIFIED: Now passes the levelDefinition
    func navigateToWritingActivity(for character: String) {
        withAnimation(.easeInOut) {
            appStateManager.currentScreen = .writingActivity(
                character: character,
                levelDefinition: self.levelDefinition // Pass the current levelDefinition
            )
        }
    }

    func navigateBackToLevelMap() {
        withAnimation(.easeInOut) {
            appStateManager.currentScreen = .levelMap
        }
    }
}
