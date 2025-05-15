//
//  WritingViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import Combine
import CoreGraphics // Keep for potential future image processing

@MainActor
class WritingViewModel: ObservableObject {
    // MARK: - Published Properties for UI
    @Published var targetCharacter: String
    @Published var instructionText: String = ""

    @Published var drawingPaths: [DrawingPath] = []
    @Published var currentDrawingPath: DrawingPath = DrawingPath()

    @Published var showValidationAlert: Bool = false
    @Published var validationMessage: String = ""

    @Published var showUnlockCelebration: Bool = false
    @Published var unlockedCharacterDisplay: String = ""

    // MARK: - Dependencies
    private var appStateManager: AppStateManager
    let levelDefinition: LevelDefinition

    init(
        appStateManager: AppStateManager,
        character: String,
        levelDefinition: LevelDefinition
    ) {
        self.appStateManager = appStateManager
        self.targetCharacter = character.uppercased()
        self.levelDefinition = levelDefinition
        self.instructionText =
            "Sekarang, coba gambar huruf \"\(self.targetCharacter)\" di kotak!"
        self.currentDrawingPath = DrawingPath(color: .black, lineWidth: 10.0) // Increased default line width
    }

    // MARK: - User Actions
    func clearDrawing() {
        drawingPaths.removeAll()
        // Reset current path with the same color and line width
        currentDrawingPath = DrawingPath(
            color: currentDrawingPath.color,
            lineWidth: currentDrawingPath.lineWidth)
        objectWillChange.send()
    }

    func submitDrawing() {
        let isCorrect = validateDrawing()

        if isCorrect {
            handleSuccessfulDrawing()
        } else {
            // This path is currently not taken due to validateDrawing always returning true
            validationMessage =
                "Gambarmu belum mirip dengan huruf \"\(targetCharacter)\". Coba lagi ya!"
            showValidationAlert = true
        }
    }

    private func validateDrawing() -> Bool {
        // For now, always consider the drawing correct if any drawing has been made.
        // In the future, actual validation logic (e.g., image comparison, path analysis) will go here.
        return !drawingPaths.isEmpty || !currentDrawingPath.points.isEmpty
    }

    private func handleSuccessfulDrawing() {
        appStateManager.characterProgress.unlockCharacter(targetCharacter)
        appStateManager.recordActivityCompletion()

        let nextCharToLearn =
            appStateManager.characterProgress.getNextCharacterToLearn()
        self.unlockedCharacterDisplay = targetCharacter
        appStateManager.setCurrentLearningCharacter(nextCharToLearn)

        withAnimation(.spring()) {
            showUnlockCelebration = true
        }
    }

    // MARK: - Navigation and Flow Control
    func celebrationDismissed() {
        guard showUnlockCelebration else { return }

        withAnimation(.spring()) {
            showUnlockCelebration = false
        }
        clearDrawing()

        let currentLevelLastChar: String
        let rangeLower = levelDefinition.range.lowerBound
        let rangeUpper = levelDefinition.range.upperBound

        if rangeLower.count == 1 && rangeUpper.count == 1
            && rangeLower <= rangeUpper
        {
            currentLevelLastChar = rangeUpper.uppercased()
        } else {
            currentLevelLastChar = "Z" // Fallback for A-Z level
            print(
                "Warning: Could not accurately determine last char for level \(levelDefinition.name) (range: \(levelDefinition.range)). Using '\(currentLevelLastChar)' as fallback."
            )
        }

        if targetCharacter.uppercased() == currentLevelLastChar {
            appStateManager.currentScreen = .levelMap
        } else {
            if let nextLearningChar = appStateManager.currentLearningCharacter,
                !nextLearningChar.isEmpty,
                nextLearningChar.uppercased()
                    != targetCharacter.uppercased()
            {
                appStateManager.currentScreen = .spellingActivity(
                    character: nextLearningChar,
                    levelDefinition: self.levelDefinition
                )
            } else {
                // Fallback if next char is same or invalid
                print(
                    "Warning: Next learning character issue after writing \(targetCharacter). Next: \(appStateManager.currentLearningCharacter ?? "nil"). Navigating to CharacterSelection."
                )
                appStateManager.currentScreen = .characterSelection(
                    levelDefinition: self.levelDefinition)
            }
        }
    }

    func navigateBackToCharacterSelection() {
        clearDrawing()
        withAnimation(.easeInOut) {
            // Navigate back to character selection of the *current* level
            appStateManager.currentScreen = .characterSelection(
                levelDefinition: self.levelDefinition)
        }
    }
}
