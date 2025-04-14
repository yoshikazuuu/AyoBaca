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
    @State private var recognizedText = "" // Keep for debug display

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

                            validateDrawingWithSimilarity { isCorrect, details in
                                self.recognizedText = details // Update status for debug

                                if isCorrect {
                                    // Update streak
                                    appStateManager.recordActivityCompletion()

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
                                                drawingPaths.removeAll() // Clear drawing for next letter
                                                recognizedText = ""
                                            }
                                        }
                                    } else {
                                        // Reached Z, go back to selection
                                        withAnimation {
                                            appStateManager.currentScreen =
                                                .characterSelection(levelId: 1)
                                        }
                                    }
                                } else {
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
                                .foregroundColor(Color("AppYellow", bundle: nil))
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 180, height: 180)
                                )

                            ConfettiView() // Ensure this view exists
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
                            .onTapGesture { showDebugImage = false } // Close on tap

                        VStack {
                            Text("Processed Image for Analysis")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top)

                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .background(Color.white) // White background for clarity
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
            .navigationBarHidden(true) // Hide navigation bar if part of NavigationView
        }
    }

    // Generate a processed image that's better for character recognition/analysis
    func generateProcessedImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // Fill with white background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Draw black lines
            UIColor.black.setStroke()
            // Increased thickness for better analysis/potential OCR later
            context.cgContext.setLineWidth(20.0)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)

            // Center and scale the drawing
            if !drawingPaths.isEmpty {
                let allPoints = drawingPaths.flatMap { $0.points }
                guard let firstPoint = allPoints.first else { return }

                var minX = firstPoint.x, minY = firstPoint.y
                var maxX = firstPoint.x, maxY = firstPoint.y

                for point in allPoints {
                    minX = min(minX, point.x)
                    minY = min(minY, point.y)
                    maxX = max(maxX, point.x)
                    maxY = max(maxY, point.y)
                }

                let drawingWidth = max(maxX - minX, 1) // Avoid division by zero
                let drawingHeight = max(maxY - minY, 1)

                // Scale factor to fit in the center with padding
                let scaleFactor = min(
                    (size.width * 0.7) / drawingWidth, // Use 70% of canvas
                    (size.height * 0.7) / drawingHeight
                )

                // Translation to center
                let centerX = size.width / 2
                let centerY = size.height / 2
                let drawingCenterX = minX + drawingWidth / 2
                let drawingCenterY = minY + drawingHeight / 2

                // Apply transformations: Translate to origin, scale, translate to center
                context.cgContext.translateBy(x: centerX, y: centerY)
                context.cgContext.scaleBy(x: scaleFactor, y: scaleFactor)
                context.cgContext.translateBy(
                    x: -drawingCenterX,
                    y: -drawingCenterY
                )

                // Draw the paths in the transformed context
                for path in drawingPaths {
                    guard let first = path.points.first else { continue }
                    context.cgContext.beginPath()
                    context.cgContext.move(to: first)
                    for point in path.points.dropFirst() {
                        context.cgContext.addLine(to: point)
                    }
                    context.cgContext.strokePath()
                }
            }
        }
        // Optional: Further processing like thresholding if needed
        // return processImageForCharacterRecognition(image, size: size)
        return image // Return the centered and scaled image directly for now
    }

    // --- Validation Logic ---

    func validateDrawingWithSimilarity(
        completion: @escaping (Bool, String) -> Void
    ) {
        // 1. Check if there's enough drawing data
        let totalPoints = drawingPaths.flatMap { $0.points }.count
        if drawingPaths.isEmpty || totalPoints < 15 { // Require a minimum number of points
            completion(false, "Gambar terlalu sedikit, coba lagi.")
            return
        }

        // 2. Analyze the general shape based on paths and points
        let allPoints = drawingPaths.flatMap { $0.points }
        let validationResult = analyzeDrawnShape(
            paths: allPoints,
            targetCharacter: character
        )

        completion(validationResult.isValid, validationResult.details)
    }

    // Expanded shape analysis for A-Z
    func analyzeDrawnShape(
        paths: [CGPoint], targetCharacter: String
    ) -> (isValid: Bool, details: String) {
        let pathCount = drawingPaths.count
        let pointCount = paths.count

        // Find drawing bounds
        guard let firstPoint = paths.first else {
            return (false, "Tidak ada gambar terdeteksi")
        }

        var minX = firstPoint.x, minY = firstPoint.y
        var maxX = firstPoint.x, maxY = firstPoint.y

        for point in paths {
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }

        // Add small epsilon to avoid division by zero
        let width = max(maxX - minX, 1e-6)
        let height = max(maxY - minY, 1e-6)
        let aspectRatio = width / height // Width relative to Height

        let char = targetCharacter.uppercased()
        var isValid = true // Assume valid initially
        var details = "" // Start with empty details

        // --- Character Specific Rules (Simplified) ---
        switch char {
        // Strokes: Typical number of distinct lines/curves used.
        // Aspect Ratio: width/height. > 1 means wider, < 1 means taller.

        case "A":
            if pathCount < 3 || pathCount > 4 { isValid = false; details = "Coba gambar 'A' dengan 2 atau 3 garis." }
            else if aspectRatio < 0.5 || aspectRatio > 1.3 { isValid = false; details = "Bentuk 'A' sepertinya kurang pas." }
        case "B":
            if pathCount < 1 || pathCount > 4 { isValid = false; details = "Coba gambar 'B' dengan 1, 2, atau 3 garis." }
            else if aspectRatio > 0.9 { isValid = false; details = "'B' biasanya lebih tinggi daripada lebar." }
        case "C":
            if pathCount > 2 { isValid = false; details = "Coba gambar 'C' dengan 1 garis melengkung." }
            else if aspectRatio < 0.6 { isValid = false; details = "'C' biasanya tidak terlalu tinggi." }
        case "D":
            if pathCount < 1 || pathCount > 3 { isValid = false; details = "Coba gambar 'D' dengan 1 atau 2 garis." }
            else if aspectRatio > 1.0 { isValid = false; details = "'D' biasanya lebih tinggi." }
        case "E":
            if pathCount < 2 || pathCount > 5 { isValid = false; details = "Coba gambar 'E' dengan 3 atau 4 garis lurus." }
            else if aspectRatio < 0.5 { isValid = false; details = "'E' biasanya tidak terlalu tinggi." }
        case "F":
            if pathCount < 2 || pathCount > 4 { isValid = false; details = "Coba gambar 'F' dengan 2 atau 3 garis lurus." }
            else if aspectRatio > 1.0 { isValid = false; details = "'F' biasanya lebih tinggi." }
        case "G":
            if pathCount < 1 || pathCount > 3 { isValid = false; details = "Coba gambar 'G' dengan 1 atau 2 garis." }
            // G is complex, less strict on aspect ratio
        case "H":
            if pathCount < 2 || pathCount > 4 { isValid = false; details = "Coba gambar 'H' dengan 3 garis lurus." }
            else if aspectRatio > 1.1 { isValid = false; details = "'H' biasanya lebih tinggi." }
        case "I":
            if pathCount > 3 { isValid = false; details = "Coba gambar 'I' dengan 1 garis lurus (atau 3)." }
            else if aspectRatio > 0.5 { isValid = false; details = "'I' seharusnya sangat tinggi dan kurus." }
        case "J":
            if pathCount < 1 || pathCount > 3 { isValid = false; details = "Coba gambar 'J' dengan 1 atau 2 garis." }
            else if aspectRatio > 0.9 { isValid = false; details = "'J' biasanya lebih tinggi." }
        case "K":
            if pathCount < 2 || pathCount > 4 { isValid = false; details = "Coba gambar 'K' dengan 3 garis." }
            else if aspectRatio > 1.1 { isValid = false; details = "'K' biasanya lebih tinggi." }
        case "L":
            if pathCount < 1 || pathCount > 3 { isValid = false; details = "Coba gambar 'L' dengan 2 garis lurus." }
            else if aspectRatio > 1.0 { isValid = false; details = "'L' biasanya lebih tinggi." }
        case "M":
            if pathCount < 1 || pathCount > 5 { isValid = false; details = "Coba gambar 'M' dengan 4 garis (atau 1-2)." }
            else if aspectRatio < 0.7 { isValid = false; details = "'M' biasanya lebar." }
        case "N":
            if pathCount < 1 || pathCount > 4 { isValid = false; details = "Coba gambar 'N' dengan 3 garis (atau 1-2)." }
            else if aspectRatio > 1.1 { isValid = false; details = "'N' biasanya lebih tinggi." }
        case "O":
            if pathCount > 2 { isValid = false; details = "Coba gambar 'O' dengan 1 garis melingkar." }
            else if abs(aspectRatio - 1.0) > 0.4 { isValid = false; details = "'O' seharusnya mendekati lingkaran/oval." }
        case "P":
            if pathCount < 1 || pathCount > 3 { isValid = false; details = "Coba gambar 'P' dengan 1 atau 2 garis." }
            else if aspectRatio > 0.9 { isValid = false; details = "'P' biasanya lebih tinggi." }
        case "Q":
            if pathCount < 2 || pathCount > 3 { isValid = false; details = "Coba gambar 'Q' seperti 'O' dengan ekor (2 garis)." }
            else if abs(aspectRatio - 1.0) > 0.5 { isValid = false; details = "'Q' seharusnya mendekati lingkaran." }
        case "R":
            if pathCount < 2 || pathCount > 4 { isValid = false; details = "Coba gambar 'R' dengan 2 atau 3 garis." }
            else if aspectRatio > 1.0 { isValid = false; details = "'R' biasanya lebih tinggi." }
        case "S":
            if pathCount > 2 { isValid = false; details = "Coba gambar 'S' dengan 1 garis melengkung." }
            // S is complex, less strict on aspect ratio
        case "T":
            if pathCount < 1 || pathCount > 3 { isValid = false; details = "Coba gambar 'T' dengan 2 garis lurus." }
            else if aspectRatio > 1.2 { isValid = false; details = "'T' biasanya lebih tinggi." }
        case "U":
            if pathCount > 2 { isValid = false; details = "Coba gambar 'U' dengan 1 garis melengkung di bawah." }
            else if aspectRatio < 0.5 { isValid = false; details = "'U' biasanya tidak terlalu tinggi." }
        case "V":
            if pathCount < 1 || pathCount > 3 { isValid = false; details = "Coba gambar 'V' dengan 2 garis lurus (atau 1)." }
            else if aspectRatio < 0.5 { isValid = false; details = "'V' biasanya tidak terlalu tinggi." }
        case "W":
            if pathCount < 1 || pathCount > 5 { isValid = false; details = "Coba gambar 'W' dengan 4 garis (atau 1-2)." }
            else if aspectRatio < 0.8 { isValid = false; details = "'W' biasanya lebar." }
        case "X":
            if pathCount < 2 || pathCount > 3 { isValid = false; details = "Coba gambar 'X' dengan 2 garis menyilang." }
            // X aspect ratio can vary
        case "Y":
            if pathCount < 2 || pathCount > 4 { isValid = false; details = "Coba gambar 'Y' dengan 2 atau 3 garis." }
            // Y aspect ratio can vary
        case "Z":
            if pathCount < 1 || pathCount > 4 { isValid = false; details = "Coba gambar 'Z' dengan 3 garis (atau 1)." }
            else if aspectRatio < 0.6 { isValid = false; details = "'Z' biasanya lebar." }

        default:
            // Should not happen if character is always A-Z
            details = "Karakter tidak dikenal."
            isValid = false
        }

        // Add general metrics to details if validation failed, or provide success message
        if !isValid {
            details += String(
                format: " (Metrics: paths=%d, aspect=%.2f)",
                pathCount, aspectRatio
            )
        } else {
            // If no specific rule failed, assume it's okay.
            details = "Bentuk '\(char)' terlihat bagus!"
            isValid = true // Ensure it's true if no rule failed
        }

        // Final check: Ensure there's *some* drawing if rules passed leniently
        if isValid && pointCount < 15 {
             isValid = false
             details = "Gambar terlalu sedikit, coba lagi."
        }

        // --- Debug Override ---
        #if DEBUG
        if debugMode && !isValid && pointCount >= 15 {
            // In debug mode, if it failed but had enough points, maybe accept?
            // Or just provide more info. Let's keep it failing but add note.
            details += " (Debug: Shape rules failed)"
        } else if debugMode && isValid {
             details += " (Debug: Shape rules passed)"
        }
        #endif

        return (isValid, details)
    }

    // Optional: Image processing function (if needed later)
    func processImageForCharacterRecognition(
        _ inputImage: UIImage, size: CGSize
    ) -> UIImage {
        // ... (grayscale and thresholding code from previous example if needed) ...
        return inputImage // Placeholder
    }
}

