//
//  WordFormationViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 16/05/25.
//


// ./Features/LearningActivities/LevelThree/WordFormation/WordFormationViewModel.swift
// ViewModel for the Word Formation Activity (Level 3)

import SwiftUI
import Combine
import AVFoundation

@MainActor
class WordFormationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentTask: WordTask?
    @Published var availableSyllableTiles: [SyllableTile] = []
    @Published var syllableSlots: [SyllableTile?] = []
    @Published var isWordCorrect: Bool? = nil // nil: not checked, true: correct, false: incorrect
    @Published var feedbackMessage: String = ""
    @Published var showNextButton: Bool = false
    @Published var instructionText: String =
        "Susun suku kata ini menjadi sebuah kata!"

    // MARK: - Private Properties
    private var appStateManager: AppStateManager
    private let levelDefinition: LevelDefinition
    private var wordTasks: [WordTask] = []
    private var currentTaskIndex: Int = 0
    private let speechSynthesizer = AVSpeechSynthesizer()

    // MARK: - Structs for Tasks and Tiles
    struct WordTask {
        let id = UUID()
        let imageName: String // Name of the image asset
        let targetWord: String
        let correctSyllables: [String]
        let distractorSyllables: [String]
        let soundFileName: String // For pronunciation
    }

    struct SyllableTile: Identifiable, Equatable {
        let id = UUID()
        let text: String
    }

    init(appStateManager: AppStateManager, levelDefinition: LevelDefinition) {
        self.appStateManager = appStateManager
        self.levelDefinition = levelDefinition
        loadWordTasks()
        setupCurrentTask()
    }

    private func loadWordTasks() {
        // Example tasks. In a real app, these might come from a JSON file or database.
        wordTasks = [
            WordTask(
                imageName: "icon_mata", // Placeholder - replace with actual image asset
                targetWord: "MATA",
                correctSyllables: ["MA", "TA"],
                distractorSyllables: ["KU", "CA", "SO", "GA"],
                soundFileName: "mata_sound" // Placeholder for sound
            ),
            WordTask(
                imageName: "icon_buku", // Placeholder
                targetWord: "BUKU",
                correctSyllables: ["BU", "KU"],
                distractorSyllables: ["ME", "JA", "PI", "TO"],
                soundFileName: "buku_sound" // Placeholder
            ),
            WordTask(
                imageName: "icon_meja", // Placeholder
                targetWord: "MEJA",
                correctSyllables: ["ME", "JA"],
                distractorSyllables: ["BO", "LA", "SU", "KA"],
                soundFileName: "meja_sound" // Placeholder
            ),
        ]
    }

    private func setupCurrentTask() {
        guard currentTaskIndex < wordTasks.count else {
            // All tasks completed
            feedbackMessage = "Selamat! Kamu telah menyelesaikan semua kata!"
            showNextButton = false // Or navigate back to map
            // Consider navigating back to map or showing a level completion screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.appStateManager.navigateTo(.levelMap) // Or popToRoot / specific screen
            }
            return
        }

        currentTask = wordTasks[currentTaskIndex]
        guard let task = currentTask else { return }

        // Setup slots
        syllableSlots = Array(repeating: nil, count: task.correctSyllables.count)

        // Setup available tiles
        var tiles = task.correctSyllables.map { SyllableTile(text: $0) }
        tiles.append(contentsOf: task.distractorSyllables.map {
            SyllableTile(text: $0)
        })
        availableSyllableTiles = tiles.shuffled()

        // Reset state
        isWordCorrect = nil
        feedbackMessage = ""
        showNextButton = false
        instructionText =
            "Gambar apakah ini? Susun suku katanya menjadi sebuah kata!"
    }

    func handleDrop(syllableTile: SyllableTile, atSlotIndex slotIndex: Int) {
        // Prevent dropping if slotIndex is out of bounds
        guard slotIndex < syllableSlots.count else { return }

        // If the tile is already in a slot, remove it from its old position
        if let oldSlotIndex = syllableSlots.firstIndex(where: { $0?.id == syllableTile.id }) {
            syllableSlots[oldSlotIndex] = nil
        }

        // If the target slot already has a tile, move that tile back to availableSyllableTiles
        if let displacedTile = syllableSlots[slotIndex] {
            if !availableSyllableTiles.contains(where: { $0.id == displacedTile.id }) {
                availableSyllableTiles.append(displacedTile)
            }
        }
        
        // Place the new tile in the slot
        syllableSlots[slotIndex] = syllableTile

        // Remove the placed tile from availableSyllableTiles
        availableSyllableTiles.removeAll { $0.id == syllableTile.id }

        checkWordCompletion()
    }
    
    func tileTapped(_ tappedTile: SyllableTile) {
        // Find the first empty slot
        if let emptySlotIndex = syllableSlots.firstIndex(where: { $0 == nil }) {
            // Move tile from available to the empty slot
            syllableSlots[emptySlotIndex] = tappedTile
            availableSyllableTiles.removeAll { $0.id == tappedTile.id }
            checkWordCompletion()
        }
    }

    func slotTapped(_ slotIndex: Int) {
        // If there's a tile in the tapped slot, move it back to available tiles
        if let tileToMoveBack = syllableSlots[slotIndex] {
            syllableSlots[slotIndex] = nil // Empty the slot
            if !availableSyllableTiles.contains(where: { $0.id == tileToMoveBack.id }) {
                 availableSyllableTiles.append(tileToMoveBack) // Add back to available tiles
                 availableSyllableTiles.shuffle() // Shuffle for better UX
            }
            isWordCorrect = nil // Reset correctness check
            feedbackMessage = ""
            showNextButton = false
        }
    }


    private func checkWordCompletion() {
        guard let task = currentTask else { return }
        // Check if all slots are filled
        guard !syllableSlots.contains(where: { $0 == nil }) else {
            isWordCorrect = nil
            feedbackMessage = ""
            showNextButton = false
            return
        }

        let formedWord = syllableSlots.compactMap { $0?.text }.joined()

        if formedWord == task.targetWord {
            isWordCorrect = true
            feedbackMessage = "Benar! Ini adalah \(task.targetWord)."
            showNextButton = true
            playSound(for: task.targetWord) // Play sound on correct
            appStateManager.recordActivityCompletion() // Record streak
        } else {
            isWordCorrect = false
            feedbackMessage = "Belum tepat. Coba lagi susun suku katanya."
            showNextButton = false
        }
    }

    func playCurrentWordSound() {
        guard let task = currentTask, isWordCorrect == true else { return }
        playSound(for: task.targetWord)
    }
    
    private func playSound(for text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        utterance.rate = AVSpeechUtteranceMinimumSpeechRate * 0.9
        speechSynthesizer.speak(utterance)
    }

    func nextWordTask() {
        currentTaskIndex += 1
        setupCurrentTask()
    }

    func navigateBack() {
        appStateManager.goBack()
    }
}
