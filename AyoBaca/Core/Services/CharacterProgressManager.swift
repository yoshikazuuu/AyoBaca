//
//  CharacterProgressManager.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 07/04/25.
//

import Foundation

class CharacterProgressManager: ObservableObject {
    @Published var unlockedCharacters: Set<String> = []
    private let unlockedCharactersKey = "com.ayobaca.unlockedCharacters"

    init() {
        loadProgress()
    }

    private func loadProgress() {
        if let savedCharacters = UserDefaults.standard.array(
            forKey: unlockedCharactersKey) as? [String]
        {
            unlockedCharacters = Set(savedCharacters)
            if unlockedCharacters.isEmpty { // Ensure 'A' is always unlocked
                unlockedCharacters = ["A"]
                saveProgress()
            }
        } else {
            unlockedCharacters = ["A"] // Default: Only 'A' is unlocked
            saveProgress()
        }
        print("Loaded unlocked characters: \(unlockedCharacters.sorted())")
    }

    private func saveProgress() {
        UserDefaults.standard.set(
            Array(unlockedCharacters).sorted(), forKey: unlockedCharactersKey)
        print("Saved unlocked characters: \(unlockedCharacters.sorted())")
    }

    func isCharacterUnlocked(_ character: String) -> Bool {
        return unlockedCharacters.contains(character.uppercased())
    }

    func unlockCharacter(_ character: String) {
        let upperChar = character.uppercased()
        if !unlockedCharacters.contains(upperChar) {
            unlockedCharacters.insert(upperChar)
            saveProgress()
            print(
                "Unlocked character: \(upperChar). Current unlocked: \(unlockedCharacters.sorted())"
            )
        }
    }

    func getHighestUnlockedCharacter() -> String? {
        return unlockedCharacters.sorted().last
    }

    func getNextCharacter(after character: String) -> String? {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        guard let currentUpper = character.uppercased().first,
            let currentIndex = alphabet.firstIndex(of: currentUpper)
        else {
            return nil
        }
        let nextIndex = alphabet.index(after: currentIndex)
        if nextIndex < alphabet.endIndex {
            return String(alphabet[nextIndex])
        }
        return nil
    }

    func getNextCharacterToLearn() -> String {
        guard let highest = getHighestUnlockedCharacter() else {
            return "A"
        }
        if highest == "Z" {
            return "Z"
        }
        return getNextCharacter(after: highest) ?? "A"
    }

    func resetProgress() {
        unlockedCharacters = ["A"]
        saveProgress()
        print("Character progress reset. Unlocked: \(unlockedCharacters)")
    }
}

