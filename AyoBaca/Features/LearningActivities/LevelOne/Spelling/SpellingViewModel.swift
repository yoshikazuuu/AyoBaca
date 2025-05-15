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

    // MODIFIED: init to accept levelDefinition
    init(appStateManager: AppStateManager, character: String, levelDefinition: LevelDefinition) {
        self.appStateManager = appStateManager
        self.character = character.uppercased()
        self.levelDefinition = levelDefinition // Initialize it

        let locale = Locale(identifier: "id-ID")
        self.recognizer = SFSpeechRecognizer(locale: locale) ?? SFSpeechRecognizer()
        requestSpeechAuthorization()
    }

    func viewDidAppear() {
        pulseEffect = false
    }

    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Speech recognition authorized for \(self.character)")
                default:
                    print("Speech recognition not authorized.")
                    self.feedbackMessage = "Izin mikrofon diperlukan untuk fitur ini."
                }
            }
        }
    }

    func toggleRecording() {
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
        
        showFeedback = false
        isMicActive = true
        pulseEffect = true

        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            request = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = request else {
                fatalError("Unable to create SFSpeechAudioBufferRecognitionRequest object")
            }
            recognitionRequest.shouldReportPartialResults = true

            let inputNode = audioEngine.inputNode

            recognitionTask = recognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                var isFinal = false
                if let result = result {
                    self.processSpeechResult(result.bestTranscription.formattedString)
                    isFinal = result.isFinal
                }

                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.request = nil
                    // self.recognitionTask = nil // Task nils itself out
                    
                    if self.isMicActive {
                        self.isMicActive = false
                        self.pulseEffect = false
                        if !self.showFeedback {
                             self.handleEmptyOrUnclearResult()
                        }
                    }
                }
            }

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
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
        if audioEngine.isRunning { // Check if engine is running before stopping
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        recognitionTask?.cancel()
        
        request = nil
        // recognitionTask = nil // Task nils itself out

        isMicActive = false
        pulseEffect = false

        if !processed && !showFeedback {
            handleEmptyOrUnclearResult()
        }
    }
    
    private func handleRecordingError() {
        isMicActive = false
        pulseEffect = false
        feedbackMessage = "Gagal memulai rekaman. Coba lagi."
        showTip = false // Don't show tip on recording error
        withAnimation { showFeedback = true }
    }

    private func handleEmptyOrUnclearResult() {
        isCorrectPronunciation = false
        feedbackMessage = "Suara tidak terdeteksi atau kurang jelas. Coba lagi ya!"
        showTip = true
        withAnimation { showFeedback = true }
    }

    private func processSpeechResult(_ recognizedText: String) {
        print("Speech recognized for '\(character)': \(recognizedText)")
        let lowerResult = recognizedText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        isCorrectPronunciation = checkPronunciation(result: lowerResult, expectedCharacter: character)

        if isCorrectPronunciation {
            feedbackMessage = "Bagus Sekali! Kamu mengucapkan huruf \(character) dengan benar! 👏"
            showTip = false
            // Unlock character and update learning state
            appStateManager.characterProgress.unlockCharacter(character)
            let nextCharToLearn = appStateManager.characterProgress.getNextCharacterToLearn()
            appStateManager.setCurrentLearningCharacter(nextCharToLearn)
            appStateManager.recordActivityCompletion() // Record streak

            stopRecording(processed: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withTransaction(Transaction(animation: nil)) {
                    // MODIFIED: Pass self.levelDefinition to writingActivity
                    self.appStateManager.currentScreen = .writingActivity(
                        character: self.character, // Current character being practiced
                        levelDefinition: self.levelDefinition
                    )
                }
            }
        } else {
            if lowerResult.isEmpty {
                feedbackMessage = "Suara tidak terdeteksi. Coba lagi dengan suara yang lebih jelas."
            } else {
                feedbackMessage = "Terdengar seperti kamu mengucapkan '\(recognizedText)'. Coba ucapkan '\(getExpectedPronunciation(character).uppercased())' dengan jelas."
            }
            showTip = true
            // Don't stop recording immediately on incorrect if you want to give user a chance
            // or if SFSpeechRecognitionTask is set to not report partial results and end on its own.
            // However, if it's a final result and incorrect, stopping is fine.
            // The `isFinal` check in the recognitionTask handler already calls stopRecording.
        }
        withAnimation { showFeedback = true }
    }

    private func checkPronunciation(result: String, expectedCharacter: String) -> Bool {
        let expected = getExpectedPronunciation(expectedCharacter).lowercased()
        if result.contains(expected) { return true }

        let alternatives = alternativePronunciations(for: expectedCharacter)
        for alt in alternatives {
            if result.contains(alt.lowercased()) { return true }
        }
        return result.contains(expectedCharacter.lowercased())
    }

    private func getExpectedPronunciation(_ char: String) -> String {
        switch char.lowercased() {
        case "a": return "a"; case "b": return "be"; case "c": return "ce"; case "d": return "de"
        case "e": return "e"; case "f": return "ef"; case "g": return "ge"; case "h": return "ha"
        case "i": return "i"; case "j": return "je"; case "k": return "ka"; case "l": return "el"
        case "m": return "em"; case "n": return "en"; case "o": return "o"; case "p": return "pe"
        case "q": return "ki"; case "r": return "er"; case "s": return "es"; case "t": return "te"
        case "u": return "u"; case "v": return "ve"; case "w": return "we"; case "x": return "eks"
        case "y": return "ye"; case "z": return "zet"; default: return char
        }
    }

    private func alternativePronunciations(for char: String) -> [String] {
        switch char.lowercased() {
        case "a": return ["ah"]; case "b": return ["beh"]; case "c": return ["se", "che"]
        case "d": return ["da", "deh"]; case "e": return ["eh"]; case "f": return ["eff"]
        case "g": return ["gee", "geh"]; case "h": return ["heh"]; case "i": return ["ai", "ih"]
        case "j": return ["jay", "jeh"]; case "k": return ["kah"]; case "l": return ["ell"]
        case "m": return ["um", "emm"]; case "n": return ["in", "enn"]; case "o": return ["oh"]
        case "p": return ["pee", "peh"]; case "q": return ["kiu"]; case "r": return ["ar", "err"]
        case "s": return ["ess"]; case "t": return ["tay", "teh"]; case "u": return ["oo", "yoo"]
        case "v": return ["vee", "feh"]; case "w": return ["double u", "weh"]
        case "x": return ["ex"]; case "y": return ["why", "yeh"]; case "z": return ["zed", "zet"]
        default: return []
        }
    }

    func getTipForCharacter() -> String {
        switch character.lowercased() {
        case "a": return "Ucapkan seperti 'ah' dengan mulut terbuka."; case "b": return "Ucapkan 'be' dengan bibir yang tertutup rapat di awal."
        case "c": return "Ucapkan 'ce' seperti pada kata 'celana'."; case "d": return "Ucapkan 'de' dengan lidah menyentuh langit-langit mulut."
        case "e": return "Ucapkan 'e' seperti pada kata 'enak'."; case "f": return "Ucapkan 'ef' dengan bibir bawah menyentuh gigi atas."
        case "g": return "Ucapkan 'ge' seperti pada kata 'gelas'."; case "h": return "Ucapkan 'ha' dengan hembusan napas."
        case "i": return "Ucapkan 'i' seperti pada kata 'ikan'."; case "j": return "Ucapkan 'je' seperti pada kata 'jalan'."
        case "k": return "Ucapkan 'ka' dengan lidah menyentuh langit-langit belakang."; case "l": return "Ucapkan 'el' dengan lidah di depan langit-langit mulut."
        case "m": return "Ucapkan 'em' dengan bibir tertutup."; case "n": return "Ucapkan 'en' dengan lidah di belakang gigi."
        case "o": return "Ucapkan 'o' seperti pada kata 'obat'."; case "p": return "Ucapkan 'pe' dengan bibir tertutup rapat di awal."
        case "q": return "Ucapkan 'ki' seperti pada kata 'kita'."; case "r": return "Ucapkan 'er' dengan lidah bergetar."
        case "s": return "Ucapkan 'es' dengan lidah di belakang gigi."; case "t": return "Ucapkan 'te' dengan lidah di belakang gigi atas."
        case "u": return "Ucapkan 'u' seperti pada kata 'udara'."; case "v": return "Ucapkan 've' dengan bibir bawah menyentuh gigi atas."
        case "w": return "Ucapkan 'we' dengan bibir membulat."; case "x": return "Ucapkan 'eks' seperti pada kata 'ekstrim'."
        case "y": return "Ucapkan 'ye' seperti pada kata 'yakin'."; case "z": return "Ucapkan 'zet' seperti pada kata 'zebra'."
        default: return "Coba ucapkan dengan suara yang jelas."
        }
    }

    func navigateBackToCharacterSelection() {
        stopRecording(processed: true)
        // MODIFIED: Use self.levelDefinition for navigation
        appStateManager.currentScreen = .characterSelection(levelDefinition: self.levelDefinition)
    }
}
