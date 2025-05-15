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
            range: " "..." ", // Placeholder range
            name: "Dunia Suku Kata (Segera Hadir)"
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
            let status: LevelStatus = (definition.id == 1) ? .current : .locked
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
            "Updated Level Statuses (A-Z focus): \(self.levels.map { "ID: \($0.id) Status: \($0.status) Name: \($0.name)" })"
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

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            // Pass the whole LevelDefinition object
            appStateManager.currentScreen = .characterSelection(levelDefinition: tappedLevelDefinition)
        }
    }

    func navigateBackToDashboard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            appStateManager.currentScreen = .mainApp
        }
    }
}
