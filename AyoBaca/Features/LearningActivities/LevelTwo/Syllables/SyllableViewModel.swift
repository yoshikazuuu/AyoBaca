//
//  SyllableViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 16/05/25.
//


import SwiftUI
import Combine
import AVFoundation

@MainActor
class SyllableViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var availableLetters: [LetterTile] = []
    @Published var slotLetters: [LetterTile?] = [nil, nil] // Default two slots for CV
    @Published var isCorrectCombination: Bool? = nil // nil = not checked yet
    @Published var feedbackMessage: String = ""
    @Published var showNextButton: Bool = false
    @Published var currentTaskType: TaskType = .cv
    @Published var slotCount: Int = 2 // Default for CV task
    
    // MARK: - Types and Constants
    enum TaskType {
        case cv   // Consonant-Vowel
        case v    // Vowel only
        case cvc  // Consonant-Vowel-Consonant
        
        var instructions: String {
            switch self {
            case .cv: return "Susun huruf-huruf untuk membuat sila. Geser huruf ke dalam kotak."
            case .v: return "Sekarang, mari buat sila dengan satu huruf vokal saja."
            case .cvc: return "Wah, kamu hebat! Sekarang mari buat sila dengan tiga huruf."
            }
        }
    }
    
    struct LetterTile: Identifiable, Equatable {
        let id = UUID()
        let letter: String
        let type: LetterType
    }
    
    enum LetterType {
        case consonant
        case vowel
    }
    
    // MARK: - Private Properties
    private var appStateManager: AppStateManager
    private let levelDefinition: LevelDefinition
    private var validCombinations: Set<String> = []
    private var audioPlayer: AVAudioPlayer?
    private var taskSequence: [TaskType] = [.cv, .v, .cvc]
    private var currentTaskIndex = 0
    
    // MARK: - Initialization
    init(appStateManager: AppStateManager, levelDefinition: LevelDefinition) {
        self.appStateManager = appStateManager
        self.levelDefinition = levelDefinition
        setupTask(.cv) // Start with Consonant-Vowel task
    }
    
    // MARK: - Public Methods
    func setupTask(_ taskType: TaskType) {
        currentTaskType = taskType
        
        // Reset state
        isCorrectCombination = nil
        feedbackMessage = ""
        showNextButton = false
        
        // Configure for task type
        switch taskType {
        case .cv:
            slotCount = 2
            slotLetters = [nil, nil]
            setupCVTask()
        case .v:
            slotCount = 1
            slotLetters = [nil]
            setupVTask()
        case .cvc:
            slotCount = 3
            slotLetters = [nil, nil, nil]
            setupCVCTask()
        }
    }
    
    func handleDrop(letter: String, at index: Int) {
        // Find the letter in available tiles
        guard let tileIndex = availableLetters.firstIndex(where: { $0.letter == letter }) else {
            return
        }
        
        let tile = availableLetters[tileIndex]
        
        // If something's already in that slot, put it back in available letters
        if let existingTile = slotLetters[index] {
            availableLetters.append(existingTile)
        }
        
        // Update the slots
        slotLetters[index] = tile
        availableLetters.remove(at: tileIndex)
        
        // Check if the combination is valid
        checkCurrentCombination()
    }
    
    func checkCurrentCombination() {
        // Make sure all slots are filled
        if slotLetters.contains(where: { $0 == nil }) {
            isCorrectCombination = nil
            feedbackMessage = ""
            return
        }
        
        // Get the current combination
        let combination = slotLetters.compactMap { $0?.letter }.joined()
        
        if validCombinations.contains(combination) {
            isCorrectCombination = true
            feedbackMessage = "Benar! Kamu berhasil membuat sila \(combination)"
            showNextButton = true
            
            // Simulated haptic success feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            isCorrectCombination = false
            feedbackMessage = "Ini bukan sila yang benar. Coba lagi."
            
            // Simulated error feedback
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    func playSound() {
        // In a real implementation, this would play the corresponding audio file
        // This is a placeholder that would be replaced by actual AVAudioPlayer implementation
        print("Playing sound for syllable: \(slotLetters.compactMap { $0?.letter }.joined())")
    }
    
    func nextTask() {
        currentTaskIndex += 1
        if currentTaskIndex < taskSequence.count {
            setupTask(taskSequence[currentTaskIndex])
        } else {
            // All tasks completed, return to map
            appStateManager.navigateTo(.levelMap)
        }
    }
    
    func navigateBack() {
        appStateManager.navigateTo(.levelMap)
    }
    
    // MARK: - Private Methods
    private func setupCVTask() {
        // Create letter tiles for CV combinations
        let consonants = ["B", "D", "K", "L", "M", "P", "S", "T"]
        let vowels = ["A", "I", "U", "E", "O"]
        
        availableLetters = []
        // Add a subset of consonants and vowels (not all, to avoid clutter)
        availableLetters.append(contentsOf: consonants.prefix(4).map { LetterTile(letter: $0, type: .consonant) })
        availableLetters.append(contentsOf: vowels.prefix(2).map { LetterTile(letter: $0, type: .vowel) })
        availableLetters.shuffle()
        
        // Define valid combinations
        validCombinations = Set([
            "BA", "BI", "BU", "BE", "BO",
            "DA", "DI", "DU", "DE", "DO",
            "KA", "KI", "KU", "KE", "KO",
            "LA", "LI", "LU", "LE", "LO",
            "MA", "MI", "MU", "ME", "MO",
            "PA", "PI", "PU", "PE", "PO",
            "SA", "SI", "SU", "SE", "SO",
            "TA", "TI", "TU", "TE", "TO"
        ])
    }
    
    private func setupVTask() {
        // Create letter tiles for V task
        let vowels = ["A", "I", "U", "E", "O"]
        availableLetters = vowels.map { LetterTile(letter: $0, type: .vowel) }
        availableLetters.shuffle()
        
        // All single vowels are valid
        validCombinations = Set(vowels)
    }
    
    private func setupCVCTask() {
        // Create letter tiles for CVC task
        let initialConsonants = ["B", "D", "K", "L", "M", "P", "S", "T"]
        let vowels = ["A", "I", "U", "E", "O"]
        let finalConsonants = ["N", "M", "R", "S", "T"]
        
        availableLetters = []
        availableLetters.append(contentsOf: initialConsonants.prefix(2).map { LetterTile(letter: $0, type: .consonant) })
        availableLetters.append(contentsOf: vowels.prefix(2).map { LetterTile(letter: $0, type: .vowel) })
        availableLetters.append(contentsOf: finalConsonants.prefix(2).map { LetterTile(letter: $0, type: .consonant) })
        availableLetters.shuffle()
        
        // Define valid combinations
        validCombinations = Set([
            "BAN", "DAN", "KAN",
            "BIN", "DIN", "MIN",
            "BUR", "KUR", "TUR",
            "BES", "MES", "TES",
            "BOT", "KOT", "POT"
        ])
    }
}
