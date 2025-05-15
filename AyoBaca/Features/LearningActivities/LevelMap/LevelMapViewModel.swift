//
//  LevelMapViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import Combine

@MainActor
class LevelMapViewModel: ObservableObject {
    @Published var levels: [LevelInfo] = []

    private var appStateManager: AppStateManager
    private var progressManager: CharacterProgressManager {
        appStateManager.characterProgress
    }

    // Level definitions with original positions for placeholders.
    // Level 1 is A-Z. Other levels are placeholders.
    private let levelDefinitions: [LevelDefinition] = [
        LevelDefinition(
            id: 1,
            position: CGPoint(x: 0.25, y: 0.11), // Original position for Level 1
            range: "A"..."Z", // Level 1 covers all alphabets
            name: "Pulau Alfabet (A-Z)"
        ),
        LevelDefinition(
            id: 2,
            position: CGPoint(x: 0.75, y: 0.48), // Original position for Level 2
            range: "CV"..."CV", // CV = Consonant-Vowel range
            name: "Dunia Suku Kata"
        ),
        LevelDefinition(
            id: 3,
            position: CGPoint(x: 0.30, y: 0.70), // Original position for Level 3
            range: " "..." ", // Placeholder range
            name: "Gunung Kata (Segera Hadir)"
        ),
        LevelDefinition(
            id: 4,
            position: CGPoint(x: 0.80, y: 0.92), // Original position for Level 4
            range: " "..." ", // Placeholder range
            name: "Sungai Cerita (Segera Hadir)"
        ),
    ]

    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
        updateLevelStatuses()
    }

    func updateLevelStatuses() {
        var updatedLevelsData: [LevelInfo] = []
        for definition in levelDefinitions {
            // Level 1 = current/unlocked, Level 2 = current/unlocked but still coming soon, others locked
            let status: LevelStatus
            if definition.id == 1 || definition.id == 2 {
                status = .current
            } else {
                status = .locked
            }
            
            updatedLevelsData.append(
                LevelInfo(
                    id: definition.id,
                    position: definition.position,
                    status: status,
                    characterRange: definition.range,
                    name: definition.name
                )
            )
        }
        self.levels = updatedLevelsData
        print(
            "Updated Level Statuses: \(self.levels.map { "ID: \($0.id) Status: \($0.status) Name: \($0.name)" })"
        )
    }

    func handleLevelTap(_ level: LevelInfo) {
        guard level.status != .locked else {
            print("Level \(level.id) (\(level.name)) is locked.")
            return
        }

        // Find the original LevelDefinition corresponding to the tapped LevelInfo
        guard let tappedLevelDefinition = levelDefinitions.first(where: { $0.id == level.id }) else {
            print("Error: Could not find LevelDefinition for tapped level ID: \(level.id)")
            return
        }

        print("Tapped Level \(level.id) (\(level.name)) with status \(level.status)")

        // Navigate based on level ID
        if level.id == 1 {
            // Level 1: Character selection
            appStateManager.navigateTo(.characterSelection(levelDefinition: tappedLevelDefinition))
        } else if level.id == 2 {
            // Level 2: Syllable activity
            appStateManager.navigateTo(.syllableActivity(levelDefinition: tappedLevelDefinition))
        } else {
            // Default for other levels (if we add more in the future)
            appStateManager.navigateTo(.characterSelection(levelDefinition: tappedLevelDefinition))
        }
    }

    func navigateBackToDashboard() {
        // This is a pop to root scenario if LevelMap is not the root.
        // Or just a goBack if dashboard is a direct parent in stack.
        // Assuming dashboard is the root of this particular flow or we want to go back one step.
        // If it's meant to go to a specific state (e.g. fresh dashboard), currentScreen setter is fine.
        // For now, let's use goBack() assuming it's a step back. If it needs to be a root pop, that can be adjusted.
        appStateManager.goBack() // Or appStateManager.currentScreen = .mainApp if it's a reset to mainApp
    }
}
