//
//  ProgressiveWordReadingViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 16/05/25.
//


// ./Features/LearningActivities/LevelFour/ProgressiveWordReading/ProgressiveWordReadingViewModel.swift
// ViewModel for the Progressive Word Reading Activity (Level 4)

import SwiftUI
import Combine
import AVFoundation

@MainActor
class ProgressiveWordReadingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentWord: WordData?
    @Published var highlightedLength: Int = 0
    @Published var attributedWordDisplay: AttributedString = ""
    @Published var progress: Double = 0.0
    @Published var instructionText: String =
        "Kamu akan membaca 1 kata secara perlahan kemudian dengan lebih cepat!"
    @Published var showCompletionAnimation: Bool = false // For confetti or similar

    // MARK: - Private Properties
    private var appStateManager: AppStateManager
    private let levelDefinition: LevelDefinition
    private var wordList: [WordData] = []
    private var currentWordIndex: Int = 0
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var speechSpeedRate: Float = AVSpeechUtteranceMinimumSpeechRate * 1.1 // Slower
    private var canAdvanceWord: Bool = false


    struct WordData: Identifiable {
        let id = UUID()
        let text: String
        // Future: could include image, specific sound file, etc.
    }

    init(appStateManager: AppStateManager, levelDefinition: LevelDefinition) {
        self.appStateManager = appStateManager
        self.levelDefinition = levelDefinition
        loadWords()
        setupCurrentWord()
    }

    private func loadWords() {
        // Example words for Level 4
        wordList = [
            WordData(text: "rumah"),
            WordData(text: "senyum"),
            WordData(text: "buku"),
            WordData(text: "meja"),
            WordData(text: "kucing"),
            WordData(text: "sekolah"),
        ].shuffled() // Shuffle to make it a bit different each time
    }

    private func setupCurrentWord() {
        guard currentWordIndex < wordList.count else {
            // All words completed for this session
            instructionText = "Hebat! Semua kata telah dibaca."
            currentWord = nil
            attributedWordDisplay = ""
            progress = 1.0
            showCompletionAnimation = true // Trigger overall completion
            canAdvanceWord = false
            // Navigate back to map after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.appStateManager.navigateTo(.levelMap)
            }
            return
        }

        currentWord = wordList[currentWordIndex]
        highlightedLength = 0 // Start with no characters highlighted for the new word
        speechSpeedRate = AVSpeechUtteranceMinimumSpeechRate * 1.1 // Reset speed
        canAdvanceWord = false
        showCompletionAnimation = false
        updateAttributedWord()
        updateProgress()
        // Speak the first letter automatically
        // speakCurrentSegment() // Or wait for user to tap stepper
    }

    func advanceHighlight() {
        guard let word = currentWord else { return }
        
        if highlightedLength < word.text.count {
            highlightedLength += 1
            updateAttributedWord()
            updateProgress()
            speakCurrentSegment()

            if highlightedLength == word.text.count {
                // Word fully revealed
                instructionText = "Bagus! Ucapkan sekali lagi lebih cepat!"
                speechSpeedRate = AVSpeechUtteranceDefaultSpeechRate * 0.9 // Faster
                canAdvanceWord = true // Allow advancing to next word
                showCompletionAnimation = true // Confetti for this word
                appStateManager.recordActivityCompletion() // Record streak
                
                // Automatically play the full word faster after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.playFullWordSound(useConfiguredSpeed: true)
                }
                // Hide confetti for this word after a bit
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    self.showCompletionAnimation = false
                }
            }
        } else if canAdvanceWord {
            // If word is fully revealed and user taps again, move to next word
            nextWord()
        }
    }
    
    func nextWord() {
        currentWordIndex += 1
        setupCurrentWord()
    }

    private func updateAttributedWord() {
        guard let wordText = currentWord?.text else {
            attributedWordDisplay = ""
            return
        }

        var result = AttributedString()
        for (index, character) in wordText.enumerated() {
            var charString = AttributedString(String(character))
            if index < highlightedLength {
                charString.foregroundColor = .orange // Highlighted part
                charString.font = .system(size: 60, weight: .bold, design: .rounded)
            } else {
                charString.foregroundColor = .white.opacity(0.7) // Upcoming part
                charString.font = .system(size: 60, weight: .medium, design: .rounded)
            }
            result.append(charString)
        }
        attributedWordDisplay = result
    }

    private func updateProgress() {
        guard let word = currentWord, !word.text.isEmpty else {
            progress = 0.0
            return
        }
        progress = Double(highlightedLength) / Double(word.text.count)
    }

    func playFullWordSound(useConfiguredSpeed: Bool = false) {
        guard let wordText = currentWord?.text else { return }
        let utterance = AVSpeechUtterance(string: wordText)
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        utterance.rate = useConfiguredSpeed ? speechSpeedRate : AVSpeechUtteranceDefaultSpeechRate * 0.8 // Default slightly slower for this button
        speechSynthesizer.speak(utterance)
    }

    private func speakCurrentSegment() {
        guard let wordText = currentWord?.text, highlightedLength > 0, highlightedLength <= wordText.count else { return }
        
        let segmentToSpeak: String
        if highlightedLength == 1 { // Speak only the first character
            segmentToSpeak = String(wordText.prefix(1))
        } else { // Speak the whole highlighted part
            segmentToSpeak = String(wordText.prefix(highlightedLength))
        }
        
        let utterance = AVSpeechUtterance(string: segmentToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        utterance.rate = speechSpeedRate // Use the configured speed (slow then fast)
        speechSynthesizer.speak(utterance)
    }

    func navigateBack() {
        appStateManager.goBack()
    }
}
