// ./Features/LearningActivities/LevelMap/LevelMapViewModel.swift

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
            range: "CV"..."CV",
            name: "Dunia Suku Kata"
        ),
        LevelDefinition(
            id: 3,
            position: CGPoint(x: 0.30, y: 0.70),
            range: "WORD"..."WORD",
            name: "Gunung Kata"
        ),
        LevelDefinition(
            id: 4,
            position: CGPoint(x: 0.80, y: 0.92),
            range: "SENTENCE"..."SENTENCE", // Placeholder for sentence/reading structures
            name: "Sungai Cerita" // Updated name
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
            // All levels are currently accessible for testing
            if definition.id == 1 || definition.id == 2 || definition.id == 3 || definition.id == 4 {
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
        case 3:
            appStateManager.navigateTo(.wordFormationActivity(levelDefinition: tappedLevelDefinition))
        case 4: // New case for Level 4
            appStateManager.navigateTo(.progressiveWordReadingActivity(levelDefinition: tappedLevelDefinition))
        default:
            print("Navigation for level ID \(level.id) not yet implemented.")
        }
    }

    func navigateBackToDashboard() {
        appStateManager.goBack()
    }
}
