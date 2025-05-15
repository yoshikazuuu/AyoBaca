//
//  WritingViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import Combine
import CoreGraphics

@MainActor
class WritingViewModel: ObservableObject {
    // MARK: - Published Properties for UI
    @Published var targetCharacter: String
    @Published var instructionText: String = ""

    @Published var drawingPaths: [DrawingPath] = []
    @Published var currentDrawingPath: DrawingPath = DrawingPath() // Initialize with default

    @Published var showValidationAlert: Bool = false
    @Published var validationMessage: String = ""

    @Published var showUnlockCelebration: Bool = false
    @Published var unlockedCharacterDisplay: String = "" // For the character shown in celebration

    @Published var showDebugImage: Bool = false
    @Published var debugUIImage: UIImage? = nil // Using UIImage from UIKit

    // Debug mode can be toggled or set based on build configuration
    #if DEBUG
    @Published var debugMode: Bool = true // Enable by default in DEBUG
    #else
    @Published var debugMode: Bool = false
    #endif

    // MARK: - Dependencies
    private var appStateManager: AppStateManager
    let levelDefinition: LevelDefinition // Keep this for navigation context

    init(appStateManager: AppStateManager, character: String, levelDefinition: LevelDefinition) {
        self.appStateManager = appStateManager
        self.targetCharacter = character.uppercased()
        self.levelDefinition = levelDefinition
        self.instructionText = "Gambar huruf \"\(self.targetCharacter)\" di kotak!"
        // Initialize currentDrawingPath with default color/width if not done in DrawingPath struct
        self.currentDrawingPath = DrawingPath(color: .black, lineWidth: 8.0)
    }

    // MARK: - User Actions
    func clearDrawing() {
        drawingPaths.removeAll()
        currentDrawingPath = DrawingPath(color: currentDrawingPath.color, lineWidth: currentDrawingPath.lineWidth) // Reset with current settings
        objectWillChange.send() // Ensure UI updates if paths is empty
    }

    func submitDrawing() {
        // 1. (Optional) Generate an image from paths for validation
        // let imageForValidation = generateImageFromPaths(size: CGSize(width: 280, height: 280)) // Example size

        // 2. Perform Validation (Placeholder)
        // In a real app, you'd send the image/path data to a model for validation.
        let isCorrect = validateDrawing() // Placeholder

        if isCorrect {
            handleSuccessfulDrawing()
        } else {
            validationMessage = "Gambarmu belum mirip dengan huruf \"\(targetCharacter)\". Coba lagi ya!"
            showValidationAlert = true
        }
    }

    private func validateDrawing() -> Bool {
        // Placeholder validation logic
        // For now, consider it correct if there's at least one path with some points.
        guard !drawingPaths.isEmpty, drawingPaths.contains(where: { !$0.points.isEmpty }) else {
            // If only currentPath has points but not yet added to drawingPaths
            return !currentDrawingPath.points.isEmpty
        }
        return true // Simple success for now
    }

    private func handleSuccessfulDrawing() {
        // Unlock the current character
        appStateManager.characterProgress.unlockCharacter(targetCharacter)
        appStateManager.recordActivityCompletion() // Record streak

        // Determine the next character to learn
        let nextCharToLearn = appStateManager.characterProgress.getNextCharacterToLearn()
        
        // Set the character to display in the celebration
        // This could be the character just completed or the next one
        self.unlockedCharacterDisplay = targetCharacter // Or nextCharToLearn

        // Update the app's current learning character state
        // This will also save it to UserDefaults via AppStateManager
        appStateManager.setCurrentLearningCharacter(nextCharToLearn)

        // Trigger celebration
        showUnlockCelebration = true

        // Clear drawing for the next attempt or next character
        // clearDrawing() // Optionally clear immediately or after celebration
    }

    func proceedAfterCelebration() {
        showUnlockCelebration = false
        clearDrawing() // Clear drawing after celebration

        // Navigate based on whether all characters in the level are done or if there's a next one.
        // For simplicity, we'll navigate back to character selection for this level.
        // A more complex app might go to the next character directly or a level completion screen.
        if targetCharacter.uppercased() == "Z" { // Example: if 'Z' is the last
            appStateManager.currentScreen = .levelMap // Go to map if 'Z' was completed
        } else {
            // Navigate to the next character's spelling activity if desired,
            // or back to character selection.
            // For now, let's go back to character selection of the current level.
            navigateBackToCharacterSelection()
        }
    }


    // MARK: - Debug Actions
    func forceSuccessAndProceed() {
        guard debugMode else { return }
        print("DEBUG: Forcing success for \(targetCharacter)")
        handleSuccessfulDrawing()
    }

    // This function would convert drawing paths to a UIImage.
    // It's a complex graphics operation. Here's a conceptual stub.
    func generateProcessedImageFromPaths(targetSize: CGSize) {
        guard debugMode else { return }
        print("DEBUG: Generating processed image from paths (stub)...")

        // In a real implementation:
        // 1. Create a UIGraphicsImageRenderer or CGContext.
        // 2. Set background, scale, and transform.
        // 3. Iterate through `drawingPaths` and `currentDrawingPath`.
        // 4. Convert CGPoints to the context's coordinate system.
        // 5. Stroke each path using its color and lineWidth.
        // 6. Get the UIImage from the renderer/context.
        // self.debugUIImage = generatedImage

        // Placeholder: Create a simple colored square as a stand-in
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { ctx in
            UIColor.lightGray.setFill()
            ctx.fill(CGRect(origin: .zero, size: targetSize))

            // Draw a placeholder text
            let attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            let string = "Paths for \(targetCharacter)"
            let stringSize = string.size(withAttributes: attributes)
            let rect = CGRect(
                x: (targetSize.width - stringSize.width) / 2,
                y: (targetSize.height - stringSize.height) / 2,
                width: stringSize.width,
                height: stringSize.height
            )
            string.draw(in: rect, withAttributes: attributes)
        }
        self.debugUIImage = image
        self.showDebugImage = true // Show the debug image view
    }


    // MARK: - Navigation
    func navigateBackToCharacterSelection() {
        clearDrawing() // Clear drawing when navigating away
        withAnimation(.easeInOut) {
            appStateManager.currentScreen = .characterSelection(levelDefinition: self.levelDefinition)
        }
    }

    // Call this when the unlock celebration overlay is dismissed by the user
    // or after a timeout.
    func celebrationDismissed() {
        showUnlockCelebration = false
        clearDrawing() // Good to clear the canvas

        // Decide where to go next.
        // If current character was 'Z', maybe go to LevelMap.
        // Otherwise, could go to CharacterSelection or directly to next Spelling.
        if targetCharacter.uppercased() == "Z" { // Assuming Z is the end of this level
            appStateManager.currentScreen = .levelMap
        } else {
            // Or, if you want to automatically go to the *next* character's spelling:
            // if let nextLearningChar = appStateManager.currentLearningCharacter, nextLearningChar != targetCharacter {
            //    appStateManager.currentScreen = .spellingActivity(character: nextLearningChar, levelDefinition: self.levelDefinition)
            // } else {
            //    navigateBackToCharacterSelection()
            // }
            navigateBackToCharacterSelection() // Default back to selection screen
        }
    }
}
