// Features/LearningActivities/Spelling/Views/SpellingView.swift

import Speech
import SwiftUI

struct SpellingView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    let character: String

    // State for speech recognition
    @State private var isMicActive = false
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var recognizer: SFSpeechRecognizer?
    @State private var request: SFSpeechAudioBufferRecognitionRequest?

    // Feedback states
    @State private var showFeedback = false
    @State private var isCorrectPronunciation = false
    @State private var feedbackMessage = ""
    @State private var showTip = false

    // Animation state
    @State private var pulseEffect = false

    init(character: String) {
        self.character = character

        // Initialize with Indonesian locale if available
        let locale = Locale(identifier: "id-ID")
        _recognizer = State(
            initialValue: SFSpeechRecognizer(locale: locale)
                ?? SFSpeechRecognizer()
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.8, green: 0.9, blue: 1.0)
                    .ignoresSafeArea()

                VStack {
                    // Instruction Text
                    Text("Bunyikan Huruf Ini!")
                        .font(.appFont(.rethinkBold, size: 24))
                        .foregroundColor(Color.black.opacity(0.7))
                        .padding(.top, geometry.safeAreaInsets.top + 30)

                    Spacer()

                    // Character Display Box
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(
                                color: Color.black.opacity(0.1),
                                radius: 8, x: 0, y: 4
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .strokeBorder(
                                        style: StrokeStyle(
                                            lineWidth: 4,
                                            dash: [10, 8]
                                        )
                                    )
                                    .foregroundColor(
                                        Color("AppOrange").opacity(0.5)
                                    )
                            )
                            .padding(.horizontal, 40)
                            .aspectRatio(1, contentMode: .fit)

                        Text(character)
                            .font(.appFont(.dylexicBold, size: 180))
                            .foregroundColor(Color("AppOrange"))
                            .scaleEffect(pulseEffect ? 1.1 : 1.0)
                            .animation(
                                pulseEffect
                                    ? Animation.easeInOut(duration: 0.5)
                                        .repeatForever(autoreverses: true)
                                    : .default, value: pulseEffect
                            )
                    }
                    .padding(.bottom, 20)

                    Spacer()

                    if !showFeedback {
                        // Microphone Button
                        Button {
                            if isMicActive {
                                stopRecording()
                            } else {
                                startRecording()
                            }
                        } label: {
                            Image(systemName: isMicActive ? "mic.fill" : "mic")
                                .font(.system(size: 30))
                                .foregroundColor(
                                    isMicActive ? .red : Color("AppOrange")
                                )
                                .frame(width: 70, height: 70)
                                .background(
                                    Circle().fill(Color.white)
                                        .shadow(
                                            color: Color.black.opacity(0.2),
                                            radius: 5, x: 0, y: 3
                                        )
                                )
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isMicActive
                                                ? Color.red : Color.clear,
                                            lineWidth: 3
                                        )
                                        .scaleEffect(
                                            pulseEffect && isMicActive
                                                ? 1.2 : 1.0
                                        )
                                        .opacity(
                                            pulseEffect && isMicActive ? 0 : 1
                                        )
                                        .animation(
                                            isMicActive
                                                ? Animation.easeOut(duration: 1)
                                                    .repeatForever(
                                                        autoreverses: false)
                                                : .default, value: pulseEffect
                                        )
                                )
                        }
                        .padding(.bottom, 10)

                        // Instructions Text
                        if isMicActive {
                            Text("Silakan ucapkan huruf \(character)...")
                                .font(.appFont(.rethinkRegular, size: 16))
                                .foregroundColor(Color.black.opacity(0.6))
                                .padding(.bottom, 10)
                        } else {
                            Text("Tekan tombol mikrofon untuk mulai")
                                .font(.appFont(.rethinkRegular, size: 16))
                                .foregroundColor(Color.black.opacity(0.6))
                                .padding(.bottom, 10)
                        }
                    }

                    // Feedback container
                    if showFeedback {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.95))
                                .shadow(
                                    color: Color.black.opacity(0.1),
                                    radius: 8, x: 0, y: 4
                                )

                            VStack(spacing: 12) {
                                Text(
                                    isCorrectPronunciation
                                        ? "Bagus Sekali! 👏"
                                        : "Coba Lagi Ya! 💪"
                                )
                                .font(.appFont(.rethinkBold, size: 22))
                                .foregroundColor(
                                    isCorrectPronunciation
                                        ? .green : Color("AppOrange")
                                )
                                .padding(.top, 16)

                                Text(feedbackMessage)
                                    .font(.appFont(.rethinkRegular, size: 16))
                                    .foregroundColor(Color.black.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)

                                if showTip {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(alignment: .top, spacing: 8) {
                                            Image(systemName: "lightbulb.fill")
                                                .foregroundColor(
                                                    Color("AppOrange")
                                                )
                                                .padding(.top, 2)

                                            Text(
                                                "Tip: "
                                                    + getTipForCharacter(
                                                        character)
                                            )
                                            .font(
                                                .appFont(
                                                    .rethinkRegular, size: 14)
                                            )
                                            .foregroundColor(Color.black)
                                            .fixedSize(
                                                horizontal: false,
                                                vertical: true)
                                        }
                                    }
                                    .frame(
                                        maxWidth: .infinity, alignment: .leading
                                    )
                                    .padding(12)
                                    .background(Color.yellow.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 16)
                                }

                                // Only show retry button when pronunciation is incorrect.
                                if !isCorrectPronunciation {
                                    Button {
                                        withAnimation {
                                            showFeedback = false
                                        }
                                        startRecording()
                                    } label: {
                                        Text("Coba Lagi Ya! 💪")
                                            .font(
                                                .appFont(.rethinkBold, size: 18)
                                            )
                                            .foregroundColor(.white)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 24)
                                            .background(Color("AppOrange"))
                                            .cornerRadius(25)
                                            .shadow(
                                                color: Color.black.opacity(0.1),
                                                radius: 5, x: 0, y: 2
                                            )
                                    }
                                    .padding(.top, 8)
                                    .padding(.bottom, 16)
                                }
                            }
                            .padding(.vertical, 4)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(width: geometry.size.width - 40)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    }
                }
                .frame(width: geometry.size.width)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 20)

                // Back Button (Top Left)
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                appStateManager.currentScreen =
                                    .characterSelection(levelId: 1)
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.title2.weight(.semibold))
                                .padding(12)
                                .background(Color.white.opacity(0.7))
                                .foregroundColor(Color("AppOrange"))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .padding(.leading)
                        Spacer()
                    }
                    Spacer()
                }

                // ConfettiView is added and will only show when the user’s pronunciation is correct.
                if isCorrectPronunciation {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .frame(height: 200)
                    // You can further adjust its position (e.g. with .offset or .padding)
                }
            }
        }
        .onAppear {
            requestSpeechAuthorization()
            pulseEffect = false
        }
    }
    
    // MARK: - Speech Recognition Methods

    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition not authorized")
                @unknown default:
                    print("Speech recognition unknown authorization status")
                }
            }
        }
    }

    private func startRecording() {
        // Reset feedback state
        showFeedback = false
        isMicActive = true
        pulseEffect = true

        // Cancel any previous recognition task.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(
                .record,
                mode: .measurement,
                options: .duckOthers)
            try audioSession.setActive(
                true,
                options: .notifyOthersOnDeactivation)

            request = SFSpeechAudioBufferRecognitionRequest()

            guard let request = request else {
                fatalError("Unable to create speech request")
            }
            request.shouldReportPartialResults = true

            let inputNode = audioEngine.inputNode

            recognitionTask =
                recognizer?.recognitionTask(with: request) { result, error in
                    var isFinal = false
                    if let result = result {
                        isFinal = result.isFinal
                        // Process recognized text.
                        processSpeechResult(
                            result.bestTranscription
                                .formattedString)
                    }
                    if error != nil || isFinal {
                        self.audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        self.request = nil
                        self.recognitionTask = nil
                        self.isMicActive = false
                        self.pulseEffect = false
                    }
                }

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(
                onBus: 0,
                bufferSize: 1024,
                format: recordingFormat
            ) { buffer, _ in
                self.request?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Audio session/engine error: \(error.localizedDescription)")
            stopRecording()
        }
    }

    private func stopRecording() {
        audioEngine.stop()
        request?.endAudio()
        recognitionTask?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)

        request = nil
        recognitionTask = nil
        isMicActive = false
        pulseEffect = false

        if !showFeedback {
            isCorrectPronunciation = false
            feedbackMessage =
                "Suara tidak terdeteksi. Coba lagi dengan suara yang lebih jelas."
            showTip = true

            withAnimation {
                showFeedback = true
            }
        }
    }

    private func processSpeechResult(_ result: String) {
        print("Speech recognized: \(result)")
        let lowerResult = result.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let lowerExpected = getExpectedPronunciation(character)
            .lowercased()

        let pronunciationMatches =
            checkPronunciation(result: lowerResult, character: character)
        isCorrectPronunciation = pronunciationMatches

        if pronunciationMatches {
            feedbackMessage =
                "Kamu telah mengucapkan huruf \(character) dengan benar!"
            showTip = false

            // Stop any ongoing animations or heavy tasks if necessary.
            pulseEffect = false

            // Ensure audio tasks are cleaned up.
            DispatchQueue.main.async {
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
            }

            // Proceed to the writing activity after a short delay without an animation.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withTransaction(Transaction(animation: nil)) {
                    appStateManager.currentScreen = .writingActivity(
                        character: character)
                }
            }
        } else {
            if lowerResult.isEmpty {
                feedbackMessage =
                    "Suara tidak terdeteksi. Coba lagi dengan suara yang lebih jelas."
            } else {
                feedbackMessage =
                    "Terdengar seperti kamu mengucapkan '\(result)'. "
                    + "Coba ucapkan '\(lowerExpected)' dengan jelas."
            }
            showTip = true
        }

        withAnimation {
            showFeedback = true
        }
        stopRecording()
    }

    // MARK: - Pronunciation Matching

    private func checkPronunciation(result: String, character: String) -> Bool {
        let expectedPronunciation =
            getExpectedPronunciation(character).lowercased()

        if result.contains(expectedPronunciation) {
            return true
        }

        // Check additional alternative pronunciations.
        let alternatives = alternativePronunciations(for: character)
        for alt in alternatives {
            if result.contains(alt) {
                return true
            }
        }

        // Fuzzy matching using the letter itself.
        return result.contains(character.lowercased())
    }

    private func alternativePronunciations(for character: String) -> [String] {
        switch character.lowercased() {
        case "a": return ["ah"]
        case "b": return ["beh"]
        case "c": return ["se", "che"]
        case "d": return ["da", "deh"]
        case "e": return ["eh"]
        case "f": return ["eff"]
        case "g": return ["gee"]
        case "h": return ["heh"]
        case "i": return ["ai"]
        case "j": return ["jay"]
        case "k": return ["kah"]
        case "l": return ["ell"]
        case "m": return ["um"]
        case "n": return ["in"]
        case "o": return ["oh"]
        case "p": return ["pee"]
        case "q": return ["ki"]
        case "r": return ["ar", "are"]
        case "s": return ["ess"]
        case "t": return ["tay"]
        case "u": return ["oo"]
        case "v": return ["vee"]
        case "w": return ["double u"]
        case "x": return ["ex"]
        case "y": return ["why"]
        case "z": return ["zed"]
        default: return []
        }
    }

    private func getExpectedPronunciation(_ character: String) -> String {
        switch character.lowercased() {
        case "a": return "a"
        case "b": return "be"
        case "c": return "ce"
        case "d": return "de"
        case "e": return "e"
        case "f": return "ef"
        case "g": return "ge"
        case "h": return "ha"
        case "i": return "i"
        case "j": return "je"
        case "k": return "ka"
        case "l": return "el"
        case "m": return "em"
        case "n": return "en"
        case "o": return "o"
        case "p": return "pe"
        case "q": return "ki"
        case "r": return "er"
        case "s": return "es"
        case "t": return "te"
        case "u": return "u"
        case "v": return "ve"
        case "w": return "we"
        case "x": return "eks"
        case "y": return "ye"
        case "z": return "zet"
        default: return character
        }
    }

    private func getTipForCharacter(_ character: String) -> String {
        switch character.lowercased() {
        case "a": return "Ucapkan seperti 'ah' dengan mulut terbuka."
        case "b":
            return "Ucapkan 'be' dengan bibir yang tertutup rapat di awal."
        case "c": return "Ucapkan 'ce' seperti pada kata 'celana'."
        case "d":
            return "Ucapkan 'de' dengan lidah menyentuh langit-langit mulut."
        case "e": return "Ucapkan 'e' seperti pada kata 'enak'."
        case "f": return "Ucapkan 'ef' dengan bibir bawah menyentuh gigi atas."
        case "g": return "Ucapkan 'ge' seperti pada kata 'gelas'."
        case "h": return "Ucapkan 'ha' dengan hembusan napas."
        case "i": return "Ucapkan 'i' seperti pada kata 'ikan'."
        case "j": return "Ucapkan 'je' seperti pada kata 'jalan'."
        case "k":
            return "Ucapkan 'ka' dengan lidah menyentuh langit-langit belakang."
        case "l":
            return "Ucapkan 'el' dengan lidah di depan langit-langit mulut."
        case "m": return "Ucapkan 'em' dengan bibir tertutup."
        case "n": return "Ucapkan 'en' dengan lidah di belakang gigi."
        case "o": return "Ucapkan 'o' seperti pada kata 'obat'."
        case "p": return "Ucapkan 'pe' dengan bibir tertutup rapat di awal."
        case "q": return "Ucapkan 'ki' seperti pada kata 'kita'."
        case "r": return "Ucapkan 'er' dengan lidah bergetar."
        case "s": return "Ucapkan 'es' dengan lidah di belakang gigi."
        case "t": return "Ucapkan 'te' dengan lidah di belakang gigi atas."
        case "u": return "Ucapkan 'u' seperti pada kata 'udara'."
        case "v": return "Ucapkan 've' dengan bibir bawah menyentuh gigi atas."
        case "w": return "Ucapkan 'we' dengan bibir membulat."
        case "x": return "Ucapkan 'eks' seperti pada kata 'ekstrim'."
        case "y": return "Ucapkan 'ye' seperti pada kata 'yakin'."
        case "z": return "Ucapkan 'zet' seperti pada kata 'zebra'."
        default: return "Coba ucapkan dengan suara yang jelas."
        }
    }
}

#Preview {
    SpellingView(character: "A")
        .environmentObject(AppStateManager())
}
