import SwiftUI
import Combine
import AVFoundation // For AVSpeechSynthesizer

@MainActor
class PronunciationHelperViewModel: ObservableObject {
    @Published var currentCharacter: String
    let levelDefinition: LevelDefinition
    private var appStateManager: AppStateManager

    private var charactersInRange: [String] = []
    @Published var currentIndex: Int = 0

    private let speechSynthesizer = AVSpeechSynthesizer()

    init(
        appStateManager: AppStateManager,
        character: String,
        levelDefinition: LevelDefinition
    ) {
        self.appStateManager = appStateManager
        self.currentCharacter = character.uppercased()
        self.levelDefinition = levelDefinition
        
        setupCharactersInRange()
        
        if let initialIndex = charactersInRange.firstIndex(of: self.currentCharacter) {
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

      if
        let lowerScalar = lowerChar.unicodeScalars.first,
        let upperScalar = upperChar.unicodeScalars.first,
        lowerScalar.value <= upperScalar.value
      {
        // Build [“A”,“B”,…] (or any UnicodeScalar progression)
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

    func playSound() {
        let utterance = AVSpeechUtterance(string: getPhoneticSpelling(for: currentCharacter))
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID") // Indonesian voice
        utterance.rate = AVSpeechUtteranceMinimumSpeechRate * 0.9 // Slower rate
        speechSynthesizer.speak(utterance)
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
        // Navigate to SpellingActivity, pushing it onto the stack
        appStateManager.navigateTo(.spellingActivity(character: currentCharacter, levelDefinition: levelDefinition))
    }
    
    func goBack() {
        appStateManager.goBack()
    }
} 
