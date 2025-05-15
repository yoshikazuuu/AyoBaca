// ./Features/LearningActivities/LevelTwo/Syllables/SyllableViewModel.swift
// ViewModel for the Syllable construction activity (Level 2)

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
            appStateManager.recordActivityCompletion() // Record streak
            
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
        let syllable = slotLetters.compactMap { $0?.letter }.joined()
        guard !syllable.isEmpty else { return }
        
        let utterance = AVSpeechUtterance(string: syllable)
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        utterance.rate = AVSpeechUtteranceMinimumSpeechRate * 0.95 // Slightly adjusted rate
        
        // Using AVSpeechSynthesizer directly if no complex audio management is needed
        let speechSynthesizer = AVSpeechSynthesizer()
        speechSynthesizer.speak(utterance)
        print("Playing sound for syllable: \(syllable)")
    }
    
    func nextTask() {
        currentTaskIndex += 1
        if currentTaskIndex < taskSequence.count {
            setupTask(taskSequence[currentTaskIndex])
        } else {
            // All tasks completed, return to map
            feedbackMessage = "Selamat! Kamu menyelesaikan semua tugas sila!"
            // Optionally, navigate back after a delay or show a completion message longer
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.appStateManager.goBack() // Go back to level map
            }
        }
    }
    
    // Changed to use goBack for standard back navigation behavior
    func navigateBack() {
        appStateManager.goBack()
    }
    
    // MARK: - Private Methods
    private func setupCVTask() {
        // Create letter tiles for CV combinations
        let consonants = ["B", "D", "K", "L", "M", "P", "S", "T", "C", "G", "J", "N", "NY", "NG"]
        let vowels = ["A", "I", "U", "E", "O"]
        
        availableLetters = []
        // Add a subset of consonants and vowels (not all, to avoid clutter)
        // Ensure we have enough for a good selection, e.g., 4-5 consonants, 2-3 vowels
        availableLetters.append(contentsOf: consonants.shuffled().prefix(5).map { LetterTile(letter: $0, type: .consonant) })
        availableLetters.append(contentsOf: vowels.shuffled().prefix(3).map { LetterTile(letter: $0, type: .vowel) })
        availableLetters.shuffle()
        
        // Define valid combinations - expanded set
        validCombinations = Set([
            "BA", "BI", "BU", "BE", "BO", "CA", "CI", "CU", "CE", "CO",
            "DA", "DI", "DU", "DE", "DO", "GA", "GI", "GU", "GE", "GO",
            "KA", "KI", "KU", "KE", "KO", "LA", "LI", "LU", "LE", "LO",
            "MA", "MI", "MU", "ME", "MO", "NA", "NI", "NU", "NE", "NO",
            "PA", "PI", "PU", "PE", "PO", "SA", "SI", "SU", "SE", "SO",
            "TA", "TI", "TU", "TE", "TO", "YA", "YI", "YU", "YE", "YO",
            "NGA", "NGI", "NGU", "NGE", "NGO", "NYA", "NYI", "NYU", "NYE", "NYO"
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
        let initialConsonants = ["B", "D", "K", "L", "M", "P", "S", "T", "R", "N"]
        let vowels = ["A", "I", "U", "E", "O"]
        let finalConsonants = ["N", "M", "R", "S", "T", "K", "P", "NG"] // Added K, P, NG
        
        availableLetters = []
        availableLetters.append(contentsOf: initialConsonants.shuffled().prefix(3).map { LetterTile(letter: $0, type: .consonant) })
        availableLetters.append(contentsOf: vowels.shuffled().prefix(2).map { LetterTile(letter: $0, type: .vowel) })
        availableLetters.append(contentsOf: finalConsonants.shuffled().prefix(3).map { LetterTile(letter: $0, type: .consonant) })
        availableLetters.shuffle()
        
        // Define valid combinations - expanded set
        validCombinations = Set([
            "BAN", "DAN", "KAN", "LAN", "MAN", "PAN", "SAN", "TAN", "RAN",
            "BIN", "DIN", "KIN", "LIN", "MIN", "PIN", "SIN", "TIN", "RIN",
            "BUR", "DUR", "KUR", "LUR", "MUR", "PUR", "SUR", "TUR", "RUR",
            "BES", "DES", "KES", "LES", "MES", "PES", "SES", "TES", "RES",
            "BOT", "DOT", "KOT", "LOT", "MOT", "POT", "SOT", "TOT", "ROT",
            "BAK", "BIK", "BUK", "BEK", "BOK", // CVC ending in K
            "CAP", "CIP", "CUP", "CEP", "COP", // CVC ending in P
            "BANG", "BING", "BUNG", "BENG", "BONG" // CVC ending in NG
        ])
    }
}

