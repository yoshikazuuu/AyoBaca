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

    private let levelDefinitions: [LevelDefinition] = [
        LevelDefinition(
            id: 1,
            position: CGPoint(x: 0.25, y: 0.11),
            range: "A"..."Z",
            name: "Pulau Alfabet (A-Z)"
        ),
        LevelDefinition(
            id: 2,
            position: CGPoint(x: 0.75, y: 0.48),
            range: "CV"..."CV", // Placeholder for syllable structures
            name: "Dunia Suku Kata"
        ),
        LevelDefinition(
            id: 3,
            position: CGPoint(x: 0.30, y: 0.70),
            range: "WORD"..."WORD", // Placeholder for word structures
            name: "Gunung Kata" // Updated name
        ),
        LevelDefinition(
            id: 4,
            position: CGPoint(x: 0.80, y: 0.92),
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
            let status: LevelStatus
            // Level 1 (Alphabet), Level 2 (Syllables), Level 3 (Words) are current/unlocked
            if definition.id == 1 || definition.id == 2 || definition.id == 3 {
                status = .current // Or .unlocked depending on progression logic
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

        guard let tappedLevelDefinition = levelDefinitions.first(where: { $0.id == level.id }) else {
            print("Error: Could not find LevelDefinition for tapped level ID: \(level.id)")
            return
        }

        print("Tapped Level \(level.id) (\(level.name)) with status \(level.status)")

        switch level.id {
        case 1:
            appStateManager.navigateTo(.characterSelection(levelDefinition: tappedLevelDefinition))
        case 2:
            appStateManager.navigateTo(.syllableActivity(levelDefinition: tappedLevelDefinition))
        case 3: // New case for Level 3
            appStateManager.navigateTo(.wordFormationActivity(levelDefinition: tappedLevelDefinition))
        default:
            // Fallback for other potential levels, or could be an error/locked message
            print("Navigation for level ID \(level.id) not yet implemented or level is a placeholder.")
            // Optionally, navigate to a generic placeholder or show an alert
            // For now, let's assume only defined levels are tappable if not locked.
            // If it's an "upcoming" level that's not locked, you might show a "Coming Soon" view.
            // Example: appStateManager.navigateTo(.comingSoon(levelDefinition: tappedLevelDefinition))
        }
    }

    func navigateBackToDashboard() {
        appStateManager.goBack()
    }
}
