//
//  CharacterProgressManager.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 07/04/25.
//


// CharacterProgressManager.swift
import Foundation

class CharacterProgressManager: ObservableObject {
    // Published property to trigger UI updates when progress changes
    @Published var unlockedCharacters: Set<String> = []
    
    // UserDefaults key
    private let unlockedCharactersKey = "com.ayobaca.unlockedCharacters"
    
    init() {
        loadProgress()
    }
    
    // Load saved progress from UserDefaults
    private func loadProgress() {
        if let savedCharacters = UserDefaults.standard.array(forKey: unlockedCharactersKey) as? [String] {
            unlockedCharacters = Set(savedCharacters)
        } else {
            // Initial state: Only 'A' is unlocked
            unlockedCharacters = ["A"]
            saveProgress()
        }
    }
    
    // Save progress to UserDefaults
    private func saveProgress() {
        UserDefaults.standard.set(Array(unlockedCharacters), forKey: unlockedCharactersKey)
    }
    
    // Check if a character is unlocked
    func isCharacterUnlocked(_ character: String) -> Bool {
        return unlockedCharacters.contains(character)
    }
    
    // Unlock a new character
    func unlockCharacter(_ character: String) {
        unlockedCharacters.insert(character)
        saveProgress()
    }
    
    // Get the next character to be unlocked
    func getNextCharacter(after character: String) -> String? {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        if let currentIndex = alphabet.firstIndex(of: character.uppercased().first ?? "A") {
            let nextIndex = alphabet.index(after: currentIndex)
            if nextIndex < alphabet.endIndex {
                return String(alphabet[nextIndex])
            }
        }
        return nil
    }
    
    // Reset progress (for testing)
    func resetProgress() {
        unlockedCharacters = ["A"]
        saveProgress()
    }
}
