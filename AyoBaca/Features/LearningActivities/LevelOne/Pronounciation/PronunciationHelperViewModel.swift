import AVFoundation  // For AVSpeechSynthesizer
import Combine
import SwiftUI

@MainActor
class PronunciationHelperViewModel: ObservableObject {
    @Published var currentCharacter: String
    let levelDefinition: LevelDefinition
    private var appStateManager: AppStateManager

    private var charactersInRange: [String] = []
    @Published var currentIndex: Int = 0

    private let speechSynthesizer = AVSpeechSynthesizer()
    private var audioSessionConfigured = false
    
    // Add deinit to clean up resources
    deinit {
        // Safe to call nonisolated method from deinit
        deactivateAudioSessionNonisolated()
    }

    init(
        appStateManager: AppStateManager,
        character: String,
        levelDefinition: LevelDefinition
    ) {
        self.appStateManager = appStateManager
        self.currentCharacter = character.uppercased()
        self.levelDefinition = levelDefinition

        setupCharactersInRange()

        if let initialIndex = charactersInRange.firstIndex(
            of: self.currentCharacter)
        {
            self.currentIndex = initialIndex
        } else {
            // Fallback if the character is not in the range (should not happen with correct usage)
            self.currentIndex = 0
            if !charactersInRange.isEmpty {
                self.currentCharacter = charactersInRange[0]
            }
        }
    }

    private func setupCharactersInRange() {
        // Assume range.lowerBound and .upperBound are single Characters
        let lowerChar = levelDefinition.range.lowerBound
        let upperChar = levelDefinition.range.upperBound

        if let lowerScalar = lowerChar.unicodeScalars.first,
            let upperScalar = upperChar.unicodeScalars.first,
            lowerScalar.value <= upperScalar.value
        {
            // Build ["A","B",…] (or any UnicodeScalar progression)
            charactersInRange = (lowerScalar.value...upperScalar.value)
                .compactMap(UnicodeScalar.init)
                .map { String($0).uppercased() }
        } else {
            // Fallback: comma-separated list in the level name, e.g. "Å,Ä,Ö"
            let list = levelDefinition.name
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces).uppercased() }
            if !list.isEmpty {
                charactersInRange = list
            } else {
                // Final fallback to ASCII A–Z
                charactersInRange = (65...90)
                    .compactMap(UnicodeScalar.init)
                    .map { String($0) }
            }
        }

        // Make sure currentIndex/cursor is still valid
        if let i = charactersInRange.firstIndex(of: currentCharacter) {
            currentIndex = i
        } else {
            currentIndex = 0
            currentCharacter = charactersInRange.first ?? currentCharacter
        }
    }

    var helperImageName: String {
        return "\(currentCharacter.lowercased())-helper"
    }

    var canGoPrevious: Bool {
        currentIndex > 0 && !charactersInRange.isEmpty
    }

    var canGoNext: Bool {
        currentIndex < charactersInRange.count - 1 && !charactersInRange.isEmpty
    }

    // Configure audio session for playback
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            audioSessionConfigured = true
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    // Deactivate audio session when done - for use within MainActor context
    private func deactivateAudioSession() {
        if audioSessionConfigured {
            deactivateAudioSessionNonisolated()
            audioSessionConfigured = false
        }
    }
    
    // Nonisolated version that can be called from any thread including deinit
    private nonisolated func deactivateAudioSessionNonisolated() {
        // Stop any speaking first
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        // Always try to deactivate the session, without checking the flag
        // (since we can't access MainActor-isolated properties)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }

    func playSound() {
        // Configure audio session before playing
        if !audioSessionConfigured {
            configureAudioSession()
        }
        
        // Clear any pending speech
        speechSynthesizer.stopSpeaking(at: .immediate)

        // 1) Letter utterance
        let letter = getPhoneticSpelling(for: currentCharacter)
        let letterUtterance = makeUtterance(text: letter)
        // small pause before the word
        letterUtterance.postUtteranceDelay = 0.3
        speechSynthesizer.speak(letterUtterance)

        // 2) Sample-word utterance
        let word = getSampleWord(for: currentCharacter)
        let wordUtterance = makeUtterance(text: word)
        speechSynthesizer.speak(wordUtterance)
    }

    private func makeUtterance(text: String) -> AVSpeechUtterance {
        let utt = AVSpeechUtterance(string: text)
        utt.voice = AVSpeechSynthesisVoice(language: "id-ID")
        utt.rate = AVSpeechUtteranceMinimumSpeechRate * 0.9
        return utt
    }

    // Basic phonetic spelling for Indonesian alphabet
    private func getPhoneticSpelling(for char: String) -> String {
        switch char.uppercased() {
        case "A": return "a"
        case "B": return "b"
        case "C": return "c"
        case "D": return "d"
        case "E": return "e"
        case "F": return "f"
        case "G": return "g"
        case "H": return "h"
        case "I": return "i"
        case "J": return "j"
        case "K": return "k"
        case "L": return "l"
        case "M": return "m"
        case "N": return "n"
        case "O": return "o"
        case "P": return "e"
        case "Q": return "i"
        case "R": return "r"
        case "S": return "s"
        case "T": return "t"
        case "U": return "u"
        case "V": return "v"
        case "W": return "w"
        case "X": return "x"
        case "Y": return "y"
        case "Z": return "z"
        default: return char
        }
    }

    func getSampleWord(for char: String) -> String {
        switch char.uppercased() {
        case "A": return "apel"
        case "B": return "bebek"
        case "C": return "cabai"
        case "D": return "donat"
        case "E": return "es"
        case "F": return "foto"
        case "G": return "gigi"
        case "H": return "hujan"
        case "I": return "ikan"
        case "J": return "jari"
        case "K": return "kucing"
        case "L": return "lima"
        case "M": return "mata"
        case "N": return "nasi"
        case "O": return "ombak"
        case "P": return "panda"
        case "Q": return "quran"
        case "R": return "rumah"
        case "S": return "sapi"
        case "T": return "topi"
        case "U": return "ular"
        case "V": return "vas"
        case "W": return "warna"
        case "X": return "xilofon"
        case "Y": return "yoyo"
        case "Z": return "zebra"
        default: return char
        }
    }

    func nextCharacter() {
        if canGoNext {
            currentIndex += 1
            currentCharacter = charactersInRange[currentIndex]
        }
    }

    func previousCharacter() {
        if canGoPrevious {
            currentIndex -= 1
            currentCharacter = charactersInRange[currentIndex]
        }
    }

    func startPractice() {
        // Deactivate audio session before navigating
        deactivateAudioSession()
        
        // Navigate to SpellingActivity, pushing it onto the stack
        appStateManager.navigateTo(
            .spellingActivity(
                character: currentCharacter, levelDefinition: levelDefinition))
    }

    func goBack() {
        // Deactivate audio session before navigating away
        deactivateAudioSession()
        appStateManager.goBack()
    }
}
