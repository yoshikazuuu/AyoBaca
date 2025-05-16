// ./Features/LearningActivities/LevelTwo/Syllables/SyllableViewModel.swift
// ViewModel for the Syllable construction activity (Level 2)

import AVFoundation
import Combine
import SwiftUI

@MainActor
class SyllableViewModel: ObservableObject {
    // MARK: - Tutorial State
    @Published var showTutorial: Bool = true
    @Published var currentTutorialPage: Int = 0
    let tutorialPagesCount: Int = 4

    // --- Tutorial Interaction State ---
    @Published var tutorialSlotLetters: [LetterTile?] = [nil, nil]
    // Draggable 'B' specifically for tutorial page 3 (index 2 of tutorialContents)
    @Published var tutorialDraggable_B_ForPage3: LetterTile? = LetterTile(
        letter: "B", type: .consonant)
    // Static 'A' for display on tutorial page 2 (index 1 of tutorialContents)
    @Published var tutorialStatic_A_ForPage2: LetterTile? = LetterTile(
        letter: "A", type: .vowel)
    // Available letters for tutorial page 4 (index 3 of tutorialContents) - user drags 'A'
    @Published var tutorialAvailableLetters_Page4: [LetterTile] = []
    @Published var isTutorialStepCorrect: Bool? = nil
    @Published var tutorialFeedbackMessage: String = ""
    @Published var showTutorialSyllableSpeaker: Bool = false

    struct TutorialPageContent {
        let id: Int
        let instructionText: String
        let examplePrimaryText: String?
        let exampleSoundAccessibilityHint: String?
        let showBottomTilesInteractionArea: Bool
        let bottomButtonText: String
        let mascotPlaceholderText: String = "Mascot Placeholder"
        let showMainSpeakerButton: Bool
        // Flag to indicate if 'B' should be shown as pre-filled in slot 0
        // This is for tutorial page 4 (index 3)
        let shouldPrefill_B_InSlot0_ForPage4: Bool
    }

    lazy var tutorialContents: [TutorialPageContent] = [
        TutorialPageContent(
            id: 0,
            instructionText:
                "Halo Teman Belajar! Mari kita bermain dengan huruf dan membuat sila.",
            examplePrimaryText: nil, exampleSoundAccessibilityHint: nil,
            showBottomTilesInteractionArea: false, bottomButtonText: "Lanjut",
            showMainSpeakerButton: true, shouldPrefill_B_InSlot0_ForPage4: false
        ),
        TutorialPageContent(
            id: 1,
            instructionText:
                "Sila adalah bunyi yang kita ucapkan dalam satu hembusan napas.",
            examplePrimaryText: "contoh:",
            exampleSoundAccessibilityHint:
                "Tombol suara ini untuk contoh sila 'BA'.",
            showBottomTilesInteractionArea: false, bottomButtonText: "Lanjut",
            showMainSpeakerButton: true, shouldPrefill_B_InSlot0_ForPage4: false
        ),
        TutorialPageContent(
            id: 2,
            instructionText:
                "Susun huruf-huruf untuk membuat sila. Geser huruf 'B' ke dalam kotak pertama.",
            examplePrimaryText: nil,
            exampleSoundAccessibilityHint:
                "Tombol suara akan aktif jika kombinasi benar.",
            showBottomTilesInteractionArea: false, bottomButtonText: "Lanjut",
            showMainSpeakerButton: false,
            shouldPrefill_B_InSlot0_ForPage4: false),  // User drags B here
        TutorialPageContent(
            id: 3,
            instructionText:
                "Sekarang, geser huruf 'A' dari bawah ke kotak kedua untuk membuat sila 'BA'. Jika benar, sila akan berbunyi!",
            examplePrimaryText: "Selamat mencoba!",
            exampleSoundAccessibilityHint: nil,
            showBottomTilesInteractionArea: true,
            bottomButtonText: "Mulai Latihan", showMainSpeakerButton: false,
            shouldPrefill_B_InSlot0_ForPage4: true),  // B is pre-filled, user drags A
    ]

    // MARK: - Published Properties (Main Game)
    @Published var availableLetters: [LetterTile] = []
    @Published var slotLetters: [LetterTile?] = [nil, nil]  // Default two slots for CV
    @Published var isCorrectCombination: Bool? = nil  // nil = not checked yet
    @Published var feedbackMessage: String = ""
    @Published var showNextButton: Bool = false
    @Published var currentTaskType: TaskType = .cv
    @Published var slotCount: Int = 2  // Default for CV task

    enum TaskType {
        case cv
        case v
        case cvc
        var instructions: String {
            switch self {
            case .cv:
                return
                    "Susun huruf-huruf untuk membuat sila. Geser huruf ke dalam kotak."
            case .v:
                return "Sekarang, mari buat sila dengan satu huruf vokal saja."
            case .cvc:
                return
                    "Wah, kamu hebat! Sekarang mari buat sila dengan tiga huruf."
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
    public let consonants = [
        "B",
        "C",
        "D",
        "F",
        "G",
        "H",
        "J",
        "K",
        "L",
        "M",
        "N",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "V",
        "W",
        "X",
        "Y",
        "Z",
    ]
    public let vowels = ["A", "I", "U", "E", "O"]
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var taskSequence: [TaskType] = [.cv, .v, .cvc]
    private var currentTaskIndex = 0

    // MARK: - Initialization
    init(appStateManager: AppStateManager, levelDefinition: LevelDefinition) {
        self.appStateManager = appStateManager
        self.levelDefinition = levelDefinition
        if showTutorial {
            setupTutorialPageInteractions(pageId: currentTutorialPage)
        } else {
            setupTask(taskSequence[currentTaskIndex])
        }
    }

    // MARK: - Tutorial Methods
    private func resetTutorialInteractiveState(forPageId pageId: Int) {
        tutorialSlotLetters = [nil, nil]  // Always reset slots
        isTutorialStepCorrect = nil
        tutorialFeedbackMessage = ""
        showTutorialSyllableSpeaker = false

        // Reset 'B' for page 3 (index 2) if it's not already in a slot from a previous action on this page
        if pageId == 2 && tutorialSlotLetters[0]?.letter != "B" {
            tutorialDraggable_B_ForPage3 = LetterTile(
                letter: "B", type: .consonant)
        } else if pageId != 2 {  // If not on page 3, ensure B is available if needed later
            tutorialDraggable_B_ForPage3 = LetterTile(
                letter: "B", type: .consonant)
        }

        tutorialStatic_A_ForPage2 = LetterTile(letter: "A", type: .vowel)  // Always available for page 2 display

        tutorialAvailableLetters_Page4 = [
            LetterTile(letter: "A", type: .vowel),
            LetterTile(letter: "S", type: .consonant),
            LetterTile(letter: "I", type: .vowel),
            LetterTile(letter: "K", type: .consonant),
            LetterTile(letter: "M", type: .consonant),
            LetterTile(letter: "U", type: .vowel),
        ].shuffled()
    }

    func setupTutorialPageInteractions(pageId: Int) {
        resetTutorialInteractiveState(forPageId: pageId)  // Pass pageId for context
        guard pageId < tutorialContents.count else { return }
        let currentPageContent = tutorialContents[pageId]

        // Pre-fill 'B' for tutorial page 4 (index 3)
        if currentPageContent.shouldPrefill_B_InSlot0_ForPage4 {
            tutorialSlotLetters[0] = LetterTile(letter: "B", type: .consonant)
            tutorialDraggable_B_ForPage3 = nil  // B is in slot, not draggable from source
        }
    }

    func nextTutorialPage() {
        if currentTutorialPage < tutorialPagesCount - 1 {
            currentTutorialPage += 1
            setupTutorialPageInteractions(pageId: currentTutorialPage)
        } else {
            startActivity()  // Called from the button on the last tutorial page
        }
    }

    func previousTutorialPage() {
        if currentTutorialPage > 0 {
            currentTutorialPage -= 1
            setupTutorialPageInteractions(pageId: currentTutorialPage)
        }
    }

    func handleTutorialDrop(droppedTile: LetterTile, slotIndex: Int) {
        guard slotIndex < tutorialSlotLetters.count else { return }
        guard let currentContent = tutorialContents[safe: currentTutorialPage]
        else { return }

        // Page 3 (index 2 in content array) - Dragging 'B'
        if currentContent.id == 2 && droppedTile.letter == "B" && slotIndex == 0
        {
            if tutorialSlotLetters[slotIndex] == nil {
                tutorialSlotLetters[slotIndex] = droppedTile
                tutorialDraggable_B_ForPage3 = nil  // 'B' is now in slot
                isTutorialStepCorrect = true
                tutorialFeedbackMessage = "Bagus! Huruf 'B' sudah di tempatnya."
                playTutorialSuccessSound(isStep: true)
            } else {
                tutorialFeedbackMessage = "Kotak ini sudah terisi."
                isTutorialStepCorrect = false
            }
        }
        // Page 4 (index 3 in content array) - Dragging 'A'
        else if currentContent.id == 3 && droppedTile.letter == "A"
            && slotIndex == 1
        {
            guard tutorialSlotLetters[0]?.letter == "B" else {
                tutorialFeedbackMessage =
                    "Pastikan huruf 'B' sudah ada di kotak pertama ya."
                isTutorialStepCorrect = false
                return
            }
            if tutorialSlotLetters[slotIndex] == nil {
                tutorialSlotLetters[slotIndex] = droppedTile  // This should make 'A' appear
                tutorialAvailableLetters_Page4.removeAll {
                    $0.id == droppedTile.id
                }
                checkTutorialSyllableBACompletion()
            } else {
                tutorialFeedbackMessage = "Kotak ini sudah terisi."
                isTutorialStepCorrect = false
            }
        } else {
            tutorialFeedbackMessage =
                "Oops! Bukan huruf atau tempat yang tepat untuk tutorial ini."
            isTutorialStepCorrect = false
        }
    }

    private func checkTutorialSyllableBACompletion() {
        if tutorialSlotLetters[0]?.letter == "B"
            && tutorialSlotLetters[1]?.letter == "A"
        {
            isTutorialStepCorrect = true
            tutorialFeedbackMessage = "Hebat! Kamu membuat sila 'BA'!"
            showTutorialSyllableSpeaker = true
            playTutorialSuccessSound(isStep: false)  // Play "Ba" sound
        } else {
            isTutorialStepCorrect = false
            showTutorialSyllableSpeaker = false
            // Feedback might be handled by individual drop validation
        }
    }

    func playTutorialConstructedSyllableSound() {
        if showTutorialSyllableSpeaker {  // Should only be true if "BA" is formed
            speakText("Ba")
        }
    }

    private func playTutorialSuccessSound(isStep: Bool) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        if !isStep {  // Full syllable "BA"
            speakText("Ba")
        }
    }

    func startActivity() {
        showTutorial = false
        setupTask(taskSequence[currentTaskIndex])
    }

    func playTutorialSound(pageIndex: Int) {
        guard pageIndex < tutorialContents.count else { return }
        let content = tutorialContents[pageIndex]
        var textToSpeak = content.instructionText
        if content.id == 1 {  // "Sila adalah..." page, add example
            textToSpeak += " Contoh: Ba."
        }
        speakText(textToSpeak)
    }

    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        utterance.rate = AVSpeechUtteranceMinimumSpeechRate * 0.95
        speechSynthesizer.speak(utterance)
    }

    // MARK: - Public Methods (Main Game)
    func setupTask(_ taskType: TaskType) {
        currentTaskType = taskType
        isCorrectCombination = nil
        feedbackMessage = ""
        showNextButton = false
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
        guard
            let tileIndex = availableLetters.firstIndex(where: {
                $0.letter == letter
            })
        else { return }
        let tile = availableLetters[tileIndex]
        if let existingTile = slotLetters[index] {
            if !availableLetters.contains(where: { $0.id == existingTile.id }) {
                availableLetters.append(existingTile)
            }
        }
        slotLetters[index] = tile
        availableLetters.removeAll { $0.id == tile.id }
        checkCurrentCombination()
    }

    func checkCurrentCombination() {
        // Check if all slots are filled
        if slotLetters.contains(where: { $0 == nil }) {
            isCorrectCombination = nil
            feedbackMessage = ""
            showNextButton = false
            return
        }

        // Create a string representation of the current combination
        let combination = slotLetters.compactMap { $0?.letter }.joined()

        // Check if combination is valid based on task type
        let isValid = validateSyllable(
            combination: combination, taskType: currentTaskType)

        if isValid {
            isCorrectCombination = true
            feedbackMessage = "Benar! Kamu berhasil membuat sila \(combination)"
            showNextButton = true
            appStateManager.recordActivityCompletion()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            playSound()
        } else {
            isCorrectCombination = false
            feedbackMessage = "Ini bukan sila yang benar. Coba lagi."
            showNextButton = false
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    // New method to validate syllables based on pattern rather than a predefined set
    private func validateSyllable(combination: String, taskType: TaskType)
        -> Bool
    {
        // Get the letter types from the slots
        let letterTypes = slotLetters.compactMap { $0?.type }

        switch taskType {
        case .cv:
            // Valid CV syllable must have exactly 2 letters: a consonant followed by a vowel
            return letterTypes.count == 2 && letterTypes[0] == .consonant
                && letterTypes[1] == .vowel

        case .v:
            // Valid V syllable must have exactly 1 letter: a vowel
            return letterTypes.count == 1 && letterTypes[0] == .vowel

        case .cvc:
            // Valid CVC syllable must have exactly 3 letters: consonant, vowel, consonant
            return letterTypes.count == 3 && letterTypes[0] == .consonant
                && letterTypes[1] == .vowel && letterTypes[2] == .consonant
        }
    }

    func playSound() {
        let syllable = slotLetters.compactMap { $0?.letter }.joined()
        guard !syllable.isEmpty else { return }
        speakText(syllable)
    }

    func nextTask() {
        currentTaskIndex += 1
        if currentTaskIndex < taskSequence.count {
            setupTask(taskSequence[currentTaskIndex])
        } else {
            feedbackMessage = "Selamat! Kamu menyelesaikan semua tugas sila!"
            showNextButton = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.appStateManager.goBack()
            }
        }
    }

    func navigateBack() {
        if showTutorial {
            if currentTutorialPage > 0 {
                previousTutorialPage()
            } else {
                appStateManager.goBack()  // Exit from first tutorial page
            }
        } else {
            appStateManager.goBack()  // Exit from main game
        }
    }

    // MARK: - Private Methods (Main Game Data)
    private func setupCVTask() {
        // Using single-character consonants only
        let selectedConsonants = consonants.shuffled().prefix(5)
        let selectedVowels = vowels.shuffled().prefix(3)

        availableLetters = []

        // Add consonants to available letters
        availableLetters.append(
            contentsOf: selectedConsonants.map {
                LetterTile(letter: $0, type: .consonant)
            })

        // Add vowels to available letters
        availableLetters.append(
            contentsOf: selectedVowels.map {
                LetterTile(letter: $0, type: .vowel)
            })

        // Shuffle available letters
        availableLetters.shuffle()
    }

    private func setupVTask() {
        // All vowels are available for V task
        availableLetters = vowels.map { LetterTile(letter: $0, type: .vowel) }
            .shuffled()
    }

    private func setupCVCTask() {
        // Using single-character consonants only
        let selectedInitialConsonants = consonants.shuffled().prefix(3)
        let selectedVowels = vowels.shuffled().prefix(2)
        let selectedFinalConsonants = consonants.shuffled().prefix(3)

        availableLetters = []

        // Add initial consonants to available letters
        availableLetters.append(
            contentsOf: selectedInitialConsonants.map {
                LetterTile(letter: $0, type: .consonant)
            })

        // Add vowels to available letters
        availableLetters.append(
            contentsOf: selectedVowels.map {
                LetterTile(letter: $0, type: .vowel)
            })

        // Add final consonants to available letters
        availableLetters.append(
            contentsOf: selectedFinalConsonants.map {
                LetterTile(letter: $0, type: .consonant)
            })

        // Shuffle available letters
        availableLetters.shuffle()
    }
}
