//
//  SpellingViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import Combine
import Speech

@MainActor
class SpellingViewModel: ObservableObject {
    @Published var isMicActive = false
    @Published var showFeedback = false
    @Published var isCorrectPronunciation = false
    @Published var feedbackMessage = ""
    @Published var showTip = false
    @Published var pulseEffect = false

    let character: String
    private let levelDefinition: LevelDefinition // Store LevelDefinition

    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?

    private var appStateManager: AppStateManager

    private var lastMicTapTime: Date? = nil
    private let doubleTapInterval: TimeInterval = 0.4 // Seconds

    // MODIFIED: init to accept levelDefinition
    init(
        appStateManager: AppStateManager,
        character: String,
        levelDefinition: LevelDefinition
    ) {
        self.appStateManager = appStateManager
        self.character = character.uppercased()
        self.levelDefinition = levelDefinition // Initialize it

        let locale = Locale(identifier: "id-ID")
        self.recognizer =
            SFSpeechRecognizer(locale: locale) ?? SFSpeechRecognizer()
        requestSpeechAuthorization()
    }

    func viewDidAppear() {
        pulseEffect = false
        // Reset feedback states if re-entering the view for the same character
        // without completing the flow (e.g., navigating back then forward).
        showFeedback = false
        isCorrectPronunciation = false
        feedbackMessage = ""
        showTip = false
    }

    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Speech recognition authorized for \(self.character)")
                default:
                    print("Speech recognition not authorized.")
                    self.feedbackMessage =
                        "Izin mikrofon diperlukan untuk fitur ini."
                }
            }
        }
    }

    func toggleRecording() {
        let now = Date()
        if let lastTap = lastMicTapTime, now.timeIntervalSince(lastTap) < doubleTapInterval {
            // Double tap
            print("Double-tap detected on mic button.")
            lastMicTapTime = nil // Reset for next double tap
            handleDoubleClickBypass()
            return
        }
        lastMicTapTime = now // Record tap time for single tap

        if isMicActive {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            print("Cannot start recording: Speech recognition not authorized.")
            feedbackMessage = "Aktifkan izin mikrofon di Pengaturan."
            showFeedback = true
            isMicActive = false
            return
        }

        showFeedback = false // Reset feedback visibility when starting
        isMicActive = true
        pulseEffect = true

        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(
                .record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            request = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = request else {
                fatalError(
                    "Unable to create SFSpeechAudioBufferRecognitionRequest object"
                )
            }
            recognitionRequest.shouldReportPartialResults = true // Keep true for responsiveness

            let inputNode = audioEngine.inputNode

            recognitionTask = recognizer?
                .recognitionTask(with: recognitionRequest) {
                    [weak self] result, error in
                    guard let self = self else { return }
                    var isFinal = false
                    if let result = result {
                        // Process only if it's a new, more stable result or final
                        // This can help avoid premature incorrect feedback on partials
                        if result.isFinal
                            || result.bestTranscription.formattedString.count
                                > (self.feedbackMessage.count / 2)
                        { // Heuristic
                            self.processSpeechResult(
                                result.bestTranscription.formattedString)
                        }
                        isFinal = result.isFinal
                    }

                    if error != nil || isFinal {
                        self.audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        self.request = nil
                        // self.recognitionTask = nil // Task nils itself out

                        // Ensure mic is shown as inactive and feedback is handled
                        // if not already processed by processSpeechResult
                        if self.isMicActive { // Check if still active
                            self.isMicActive = false
                            self.pulseEffect = false
                            if !self.showFeedback { // If no feedback shown yet (e.g. empty result)
                                self.handleEmptyOrUnclearResult()
                            }
                        }
                    }
                }

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(
                onBus: 0, bufferSize: 1024, format: recordingFormat
            ) { buffer, _ in
                self.request?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

        } catch {
            print("Audio session/engine error: \(error.localizedDescription)")
            handleRecordingError()
        }
    }

    private func stopRecording(processed: Bool = false) {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio() // Signal end of audio if request exists
        recognitionTask?.finish() // Politely ask task to finish if it's still running
        // recognitionTask?.cancel() // Use cancel if immediate stop is needed

        request = nil
        // recognitionTask = nil // Task will nil itself out

        isMicActive = false
        pulseEffect = false

        // If recording stopped manually (e.g. user taps mic off) and no result processed
        if !processed && !showFeedback {
            handleEmptyOrUnclearResult()
        }
    }

    private func handleRecordingError() {
        isMicActive = false
        pulseEffect = false
        feedbackMessage = "Gagal memulai rekaman. Coba lagi."
        showTip = false
        withAnimation { showFeedback = true }
    }

    private func handleDoubleClickBypass() {
        print("Bypass activated for character: \(character)")

        // Ensure any ongoing recording is stopped cleanly first
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        recognitionTask?.finish() // Politely ask task to finish
        request = nil
        // recognitionTask = nil // Task will nil itself out

        isMicActive = false
        pulseEffect = false
        isCorrectPronunciation = true
        feedbackMessage = "Bagus Sekali! Kamu mengucapkan huruf \(character) dengan benar! 👏" // Changed to legitimate success message
        showTip = false
        
        withAnimation { showFeedback = true }

        // Navigate to next screen (Writing Activity)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Changed delay to 1.5s to match legitimate success
            guard self.isCorrectPronunciation, self.showFeedback else {
                // If state changed (e.g., user navigated away quickly), don't proceed
                print("Bypass navigation condition not met. isCorrect: \(self.isCorrectPronunciation), showFeedback: \(self.showFeedback)")
                return
            }
            print("Bypassing to WritingActivity for character \(self.character)")
            withTransaction(Transaction(animation: .easeInOut)) {
                self.appStateManager.currentScreen = .writingActivity(
                    character: self.character,
                    levelDefinition: self.levelDefinition
                )
            }
        }
    }

    private func handleEmptyOrUnclearResult() {
        isCorrectPronunciation = false
        feedbackMessage =
            "Suara tidak terdeteksi atau kurang jelas. Coba lagi ya!"
        showTip = true
        withAnimation { showFeedback = true }
    }

    private func processSpeechResult(_ recognizedText: String) {
        // Only process if the mic is supposed to be active to avoid late results
        guard isMicActive else { return }

        print("Speech recognized for '\(character)': \(recognizedText)")
        let lowerResult = recognizedText.lowercased().trimmingCharacters(
            in: .whitespacesAndNewlines)

        isCorrectPronunciation = checkPronunciation(
            result: lowerResult, expectedCharacter: character)

        if isCorrectPronunciation {
            feedbackMessage =
                "Bagus Sekali! Kamu mengucapkan huruf \(character) dengan benar! 👏"
            showTip = false
            // Character unlocking and progression logic is moved to WritingViewModel.
            // Streak recording is also moved to WritingViewModel.

            stopRecording(processed: true) // Stop recording as pronunciation was processed successfully

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Ensure we are still on this screen and correct before navigating
                guard self.isCorrectPronunciation, self.showFeedback else { return }
                withTransaction(Transaction(animation: .easeInOut)) {
                    self.appStateManager.currentScreen = .writingActivity(
                        character: self.character, // Current character being practiced
                        levelDefinition: self.levelDefinition
                    )
                }
            }
        } else {
            // This part will be hit if partial results are not the correct one.
            // We want to show feedback but not necessarily stop the recording yet,
            // unless SFSpeech tells us it's final.
            if lowerResult.isEmpty {
                feedbackMessage =
                    "Suara tidak terdeteksi. Coba lagi dengan suara yang lebih jelas."
            } else {
                feedbackMessage =
                    "Terdengar seperti kamu mengucapkan '\(recognizedText)'. Coba ucapkan '\(getExpectedPronunciation(character).uppercased())' dengan jelas."
            }
            showTip = true
        }
        // Update feedback visibility, this might be called multiple times for partial results
        if !showFeedback || isCorrectPronunciation { // Only animate if changing state or correct
             withAnimation { showFeedback = true }
        } else {
            showFeedback = true // Just update without animation if already showing incorrect
        }
    }

    private func checkPronunciation(
        result: String, expectedCharacter: String
    ) -> Bool {
        let expected = getExpectedPronunciation(expectedCharacter).lowercased()
        if result.contains(expected) { return true }

        let alternatives = alternativePronunciations(for: expectedCharacter)
        for alt in alternatives {
            if result.contains(alt.lowercased()) { return true }
        }
        // Last resort, check for the character itself, though less reliable for spoken form
        return result.contains(expectedCharacter.lowercased())
    }

    private func getExpectedPronunciation(_ char: String) -> String {
        switch char.lowercased() {
        case "a": return "a"; case "b": return "be"; case "c": return "ce";
        case "d": return "de"; case "e": return "e"; case "f": return "ef";
        case "g": return "ge"; case "h": return "ha"; case "i": return "i";
        case "j": return "je"; case "k": return "ka"; case "l": return "el";
        case "m": return "em"; case "n": return "en"; case "o": return "o";
        case "p": return "pe"; case "q": return "ki"; case "r": return "er";
        case "s": return "es"; case "t": return "te"; case "u": return "u";
        case "v": return "ve"; case "w": return "we"; case "x": return "eks";
        case "y": return "ye"; case "z": return "zet"; default: return char
        }
    }

    private func alternativePronunciations(for char: String) -> [String] {
        switch char.lowercased() {
        case "a": return ["ah"]; case "b": return ["beh"];
        case "c": return ["se", "che"]; case "d": return ["da", "deh"];
        case "e": return ["eh"]; case "f": return ["eff"];
        case "g": return ["gee", "geh"]; case "h": return ["hah", "he"]; // Added "he" for H
        case "i": return ["ai", "ih"]; case "j": return ["jay", "jeh"];
        case "k": return ["kah"]; case "l": return ["ell"];
        case "m": return ["um", "emm"]; case "n": return ["in", "enn"];
        case "o": return ["oh"]; case "p": return ["pee", "peh"];
        case "q": return ["kiu", "kyu"]; case "r": return ["ar", "err"]; // "kyu" for Q
        case "s": return ["ess"]; case "t": return ["tay", "teh"];
        case "u": return ["oo", "yoo"]; case "v": return ["vee", "feh"];
        case "w": return ["double u", "weh"]; case "x": return ["ex"];
        case "y": return ["why", "yeh"]; case "z": return ["zed", "zet"];
        default: return []
        }
    }

    func getTipForCharacter() -> String {
        switch character.lowercased() {
        case "a": return "Ucapkan seperti 'ah' dengan mulut terbuka.";
        case "b": return "Ucapkan 'be' dengan bibir yang tertutup rapat di awal.";
        case "c": return "Ucapkan 'ce' seperti pada kata 'celana'.";
        case "d": return "Ucapkan 'de' dengan lidah menyentuh langit-langit mulut.";
        case "e": return "Ucapkan 'e' seperti pada kata 'enak' atau 'ember'."; // Clarified 'e'
        case "f": return "Ucapkan 'ef' dengan bibir bawah menyentuh gigi atas.";
        case "g": return "Ucapkan 'ge' seperti pada kata 'gelas'.";
        case "h": return "Ucapkan 'ha' dengan hembusan napas yang jelas.";
        case "i": return "Ucapkan 'i' seperti pada kata 'ikan'.";
        case "j": return "Ucapkan 'je' seperti pada kata 'jalan'.";
        case "k": return "Ucapkan 'ka' dengan suara dari belakang tenggorokan.";
        case "l": return "Ucapkan 'el' dengan lidah di depan langit-langit mulut.";
        case "m": return "Ucapkan 'em' dengan bibir tertutup.";
        case "n": return "Ucapkan 'en' dengan lidah di belakang gigi.";
        case "o": return "Ucapkan 'o' seperti pada kata 'obat'.";
        case "p": return "Ucapkan 'pe' dengan letupan udara dari bibir.";
        case "q": return "Ucapkan 'ki' atau 'kyu'.";
        case "r": return "Ucapkan 'er' dengan lidah bergetar jika bisa.";
        case "s": return "Ucapkan 'es' dengan suara mendesis.";
        case "t": return "Ucapkan 'te' dengan lidah di belakang gigi atas.";
        case "u": return "Ucapkan 'u' seperti pada kata 'udara'.";
        case "v": return "Ucapkan 've' mirip 'ef' tapi dengan getaran suara.";
        case "w": return "Ucapkan 'we' dengan bibir membulat.";
        case "x": return "Ucapkan 'eks' gabungan 'ek' dan 'es'.";
        case "y": return "Ucapkan 'ye' seperti pada kata 'yakin'.";
        case "z": return "Ucapkan 'zet' seperti pada kata 'zebra'.";
        default: return "Coba ucapkan dengan suara yang jelas."
        }
    }

    func navigateBackToCharacterSelection() {
        stopRecording(processed: true) // Ensure recording is stopped
        withAnimation(.easeInOut) {
            appStateManager.currentScreen = .characterSelection(
                levelDefinition: self.levelDefinition)
        }
    }
}
