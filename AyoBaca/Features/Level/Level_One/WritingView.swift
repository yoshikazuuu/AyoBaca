import SwiftUI
import UIKit

struct WritingView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    let character: String

    // State for drawing paths
    @State private var drawingPaths: [DrawingPath] = []
    // State for showing unlock celebration
    @State private var showUnlockCelebration = false
    @State private var unlockedCharacter = ""

    // State for validation feedback alert
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var recognizedText = ""  // Keep for debug display

    // Debug options
    @State private var debugMode = false
    @State private var showDebugImage = false
    @State private var debugImage: UIImage?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.8, green: 0.9, blue: 1.0)
                    .ignoresSafeArea()

                VStack(spacing: 15) {
                    Text("Gambar Huruf Dikotak")
                        .font(.appFont(.rethinkBold, size: 24))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.top, geometry.safeAreaInsets.top + 30)

                    if debugMode {
                        Text("Target: \(character) | Status: \(recognizedText)")
                            .font(.footnote)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .lineLimit(2)
                    }

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
                                        style:
                                            StrokeStyle(
                                                lineWidth: 4,
                                                dash: [10, 8]
                                            )
                                    )
                                    .foregroundColor(
                                        Color("AppOrange", bundle: nil)
                                            .opacity(0.5)
                                    )
                            )

                        DrawingCanvas(
                            paths: $drawingPaths,
                            canvasColor: .clear,
                            drawingColor: .black,
                            lineWidth: 8.0
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 25))

                        Text(character)
                            .font(.appFont(.dylexicRegular, size: 200))
                            .foregroundColor(.gray.opacity(0.15))
                            .allowsHitTesting(false)
                    }
                    .padding(.horizontal, 40)
                    .aspectRatio(1, contentMode: .fit)

                    HStack(spacing: 20) {
                        Button {
                            drawingPaths.removeAll()
                            recognizedText = ""
                        } label: {
                            Label("Ulangi", systemImage: "trash")
                                .font(.appFont(.rethinkBold, size: 16))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule().fill(Color.white)
                                        .shadow(radius: 3)
                                )
                        }

                        Button {
                            let size = CGSize(width: 300, height: 300)
                            debugImage = generateProcessedImage(size: size)

                            validateDrawingWithSimilarity {
                                isCorrect, details in
                                self.recognizedText = details  // Update status for debug

                                if isCorrect {
                                    // Record streak *before* unlocking/navigating
                                    appStateManager.recordActivityCompletion()

                                    let currentUpper = character.uppercased()
                                    var nextLetter: String? = nil  // Variable to hold the next letter

                                    if currentUpper != "Z" {
                                        if let next = appStateManager
                                            .characterProgress.getNextCharacter(
                                                after: currentUpper)
                                        {
                                            appStateManager.characterProgress
                                                .unlockCharacter(next)
                                            unlockedCharacter = next
                                            nextLetter = next  // Store for navigation and state update
                                        }
                                    }

                                    // Set to the newly unlocked letter, or nil if Z was completed
                                    appStateManager.setCurrentLearningCharacter(
                                        nextLetter)

                                    // Show celebration if a new letter was unlocked
                                    if nextLetter != nil {
                                        showUnlockCelebration = true
                                    }

                                    // Navigate after a delay (or immediately if no celebration)
                                    let delay = nextLetter != nil ? 2.5 : 0.5  // Shorter delay if no celebration

                                    DispatchQueue.main.asyncAfter(
                                        deadline: .now() + delay
                                    ) {
                                        withAnimation {
                                            if let next = nextLetter {
                                                // Navigate to the next character's spelling activity
                                                appStateManager.currentScreen =
                                                    .spellingActivity(
                                                        character: next)
                                            } else {
                                                // Reached Z, go back to character selection or map
                                                appStateManager.currentScreen =
                                                    .characterSelection(
                                                        levelId:
                                                            levelIdForCharacter(
                                                                currentUpper)
                                                            ?? 1)  // Need levelId mapping
                                                // Or maybe: appStateManager.currentScreen = .levelMap
                                            }
                                            // Reset state for the next view
                                            showUnlockCelebration = false
                                            drawingPaths.removeAll()
                                            recognizedText = ""
                                        }
                                    }
                                } else {
                                    // Validation failed
                                    validationMessage =
                                        "Tulisan tidak sesuai. Coba lagi!\n\(details)"
                                    showValidationAlert = true
                                }

                            }
                        } label: {
                            Label(
                                "Selesai",
                                systemImage: "checkmark.circle.fill"
                            )
                            .font(.appFont(.rethinkBold, size: 16))
                            .foregroundColor(.green)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(Color.white)
                                    .shadow(radius: 3)
                            )
                        }
                    }
                    .padding(.top, 5)
                    .alert(isPresented: $showValidationAlert) {
                        Alert(
                            title: Text("Validasi Huruf"),
                            message: Text(validationMessage),
                            dismissButton: .default(Text("Ok"))
                        )
                    }

                    if debugMode {
                        HStack {
                            Button("Debug Image") {
                                // Ensure image is generated before showing
                                let size = CGSize(width: 300, height: 300)
                                debugImage = generateProcessedImage(size: size)
                                showDebugImage = true
                            }
                            .padding(.horizontal, 10)
                            .background(Color.blue.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)

                            Button("Force Success") {
                                // Debug button to bypass recognition
                                let currentUpper = character.uppercased()
                                if currentUpper != "Z",
                                    let firstChar = currentUpper.first,
                                    let ascii = firstChar.asciiValue
                                {
                                    let nextAscii = ascii + 1
                                    let nextLetter = String(
                                        UnicodeScalar(nextAscii)
                                    )
                                    appStateManager.characterProgress
                                        .unlockCharacter(nextLetter)
                                    unlockedCharacter = nextLetter
                                    showUnlockCelebration = true

                                    DispatchQueue.main.asyncAfter(
                                        deadline: .now() + 2.5
                                    ) {
                                        withAnimation {
                                            appStateManager.currentScreen =
                                                .spellingActivity(
                                                    character: nextLetter
                                                )
                                            showUnlockCelebration = false
                                            drawingPaths.removeAll()
                                            recognizedText = ""
                                        }
                                    }
                                } else {
                                    withAnimation {
                                        appStateManager.currentScreen =
                                            .characterSelection(levelId: 1)
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            .background(Color.purple.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.top, 5)
                    }

                    Spacer()

                    // Mascot image - ensure "mascot" exists in assets
                    Image("mascot", bundle: nil)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geometry.size.width * 1.5,
                            height: geometry.size.height * 0.5
                        )
                        // Prevent mascot from blocking bottom area interaction
                        .allowsHitTesting(false)
                }
                .frame(width: geometry.size.width)

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

                // Unlock Celebration Overlay
                if showUnlockCelebration {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            Text("Huruf Baru Terbuka!")
                                .font(.appFont(.dylexicBold, size: 28))
                                .foregroundColor(.white)

                            Text(unlockedCharacter)
                                .font(.appFont(.dylexicBold, size: 120))
                                .foregroundColor(
                                    Color("AppYellow", bundle: nil)
                                )
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 180, height: 180)
                                )

                            ConfettiView()  // Ensure this view exists
                                .allowsHitTesting(false)
                                .frame(height: 200)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    .transition(.opacity)
                }

                // Debug Image Overlay
                if showDebugImage, let image = debugImage {
                    ZStack {
                        Color.black.opacity(0.8)
                            .ignoresSafeArea()
                            .onTapGesture { showDebugImage = false }  // Close on tap

                        VStack {
                            Text("Processed Image for Analysis")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top)

                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .background(Color.white)  // White background for clarity
                                .border(Color.gray)
                                .frame(maxWidth: 300, maxHeight: 300)

                            Button("Close") {
                                showDebugImage = false
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.bottom)
                        }
                    }
                }
            }
            .navigationBarHidden(true)  // Hide navigation bar if part of NavigationView
        }
    }

    func levelIdForCharacter(_ char: String) -> Int? {
        let upperChar = char.uppercased()
        switch upperChar {
        case "A"..."E": return 1
        case "F"..."J": return 2
        case "K"..."O": return 3
        case "P"..."T": return 4
        case "U"..."Z": return 5  // Example mapping
        default: return nil
        }
    }

    func generateProcessedImage(size: CGSize) -> UIImage
    { /* ... Implementation ... */
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            UIColor.black.setStroke()
            context.cgContext.setLineWidth(20.0)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)

            if !drawingPaths.isEmpty {
                let allPoints = drawingPaths.flatMap { $0.points }
                guard let firstPoint = allPoints.first else { return }
                var minX = firstPoint.x
                var minY = firstPoint.y
                var maxX = firstPoint.x
                var maxY = firstPoint.y
                allPoints.forEach { p in
                    minX = min(minX, p.x)
                    minY = min(minY, p.y)
                    maxX = max(maxX, p.x)
                    maxY = max(maxY, p.y)
                }
                let drawingWidth = max(maxX - minX, 1)
                let drawingHeight = max(maxY - minY, 1)
                let scaleFactor = min(
                    (size.width * 0.7) / drawingWidth,
                    (size.height * 0.7) / drawingHeight)
                let centerX = size.width / 2
                let centerY = size.height / 2
                let drawingCenterX = minX + drawingWidth / 2
                let drawingCenterY = minY + drawingHeight / 2
                context.cgContext.translateBy(x: centerX, y: centerY)
                context.cgContext.scaleBy(x: scaleFactor, y: scaleFactor)
                context.cgContext.translateBy(
                    x: -drawingCenterX, y: -drawingCenterY)
                for path in drawingPaths {
                    guard let first = path.points.first else { continue }
                    context.cgContext.beginPath()
                    context.cgContext.move(to: first)
                    path.points.dropFirst().forEach {
                        context.cgContext.addLine(to: $0)
                    }
                    context.cgContext.strokePath()
                }
            }
        }
        return image
    }
    func validateDrawingWithSimilarity(
        completion: @escaping (Bool, String) -> Void
    ) { /* ... Implementation ... */
        let totalPoints = drawingPaths.flatMap { $0.points }.count
        if drawingPaths.isEmpty || totalPoints < 15 {
            completion(false, "Gambar terlalu sedikit, coba lagi.")
            return
        }
        let allPoints = drawingPaths.flatMap { $0.points }
        let validationResult = analyzeDrawnShape(
            paths: allPoints, targetCharacter: character)
        completion(validationResult.isValid, validationResult.details)
    }
    func analyzeDrawnShape(paths: [CGPoint], targetCharacter: String) -> (
        isValid: Bool, details: String
    ) { /* ... Implementation ... */
        // Simplified logic - replace with your actual analysis
        let pathCount = drawingPaths.count
        let pointCount = paths.count
        guard pointCount >= 15 else { return (false, "Kurang detail.") }

        // Basic check based on expected strokes (very rough)
        let char = targetCharacter.uppercased()
        var expectedStrokes: ClosedRange<Int> = 1...3  // Default guess
        switch char {
        case "A", "H", "K", "N", "R", "X", "Y", "Z": expectedStrokes = 2...4
        case "E", "F", "M", "W": expectedStrokes = 2...5
        case "I", "T": expectedStrokes = 1...3
        case "B": expectedStrokes = 1...4  // Can be drawn in many ways
        default: expectedStrokes = 1...3  // C, D, G, J, L, O, P, Q, S, U, V
        }

        if !expectedStrokes.contains(pathCount) {
            //return (false, "Jumlah goresan (\(pathCount)) tidak seperti huruf '\(char)'.")
            print(
                "Stroke count mismatch (\(pathCount) vs \(expectedStrokes)) for \(char) - ignoring for now"
            )  // Make it lenient
        }

        // Placeholder: Assume correct for now if enough points drawn
        print(
            "Shape analysis for \(char): \(pathCount) paths, \(pointCount) points. Assuming OK."
        )
        return (true, "Bentuk '\(char)' terlihat bagus!")
    }

    // Optional: Image processing function (if needed later)
    func processImageForCharacterRecognition(
        _ inputImage: UIImage, size: CGSize
    ) -> UIImage {
        // ... (grayscale and thresholding code from previous example if needed) ...
        return inputImage  // Placeholder
    }
}
