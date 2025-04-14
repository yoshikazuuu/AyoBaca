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
            // Ensure 'A' is always unlocked if the set is somehow empty after loading
            if unlockedCharacters.isEmpty {
                unlockedCharacters = ["A"]
                saveProgress()
            }
        } else {
            unlockedCharacters = ["A"]  // Default: Only 'A' is unlocked
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
        // Only insert if it's not already there to avoid unnecessary saves/updates
        if !unlockedCharacters.contains(upperChar) {
            unlockedCharacters.insert(upperChar)
            saveProgress()
            print(
                "Unlocked character: \(upperChar). Current unlocked: \(unlockedCharacters.sorted())"
            )
        }
    }

    // Finds the highest unlocked character alphabetically
    func getHighestUnlockedCharacter() -> String? {
        return unlockedCharacters.sorted().last
    }

    // Gets the next character in the alphabet after a given one
    func getNextCharacter(after character: String) -> String? {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        guard let currentUpper = character.uppercased().first,
            let currentIndex = alphabet.firstIndex(of: currentUpper)
        else {
            return nil  // Invalid input character
        }

        let nextIndex = alphabet.index(after: currentIndex)
        if nextIndex < alphabet.endIndex {
            return String(alphabet[nextIndex])
        }
        return nil  // Reached the end of the alphabet
    }

    // --- New Helper: Get the next character the user should learn ---
    func getNextCharacterToLearn() -> String {
        guard let highest = getHighestUnlockedCharacter() else {
            // Should not happen if 'A' is always unlocked, but handle defensively
            return "A"
        }
        // If highest is Z, they've finished
        if highest == "Z" {
            // What should happen when Z is done? Return Z or nil? Let's return Z for now.
            return "Z"
        }
        // Otherwise, return the character after the highest unlocked one
        return getNextCharacter(after: highest) ?? "A"  // Default to A if something goes wrong
    }
    // --- End New Helper ---

    func resetProgress() {
        unlockedCharacters = ["A"]
        saveProgress()
        print("Character progress reset. Unlocked: \(unlockedCharacters)")
    }
}
