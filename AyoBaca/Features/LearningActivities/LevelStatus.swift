//
//  LevelStatus.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 06/04/25.
//

// LevelMapView.swift

import SwiftUI

// Define the status for each level
enum LevelStatus {
    case locked
    case unlocked
    case current  // The level the user is currently on
}

// Structure to hold information about each level marker
struct LevelInfo: Identifiable {
    let id: Int  // Level number (1, 2, 3, ...)
    let position: CGPoint  // Relative position (x, y) from 0.0 to 1.0
    var status: LevelStatus
    let characterRange: ClosedRange<String>  // Add character range
}

struct LevelMapView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @Environment(\.dismiss) var dismiss  // Alternative way to go back if needed

    // --- Level Data ---
    // Adjust positions (x, y) based on your background image layout
    // (0,0) is top-left, (1,1) is bottom-right
    private let levelDefinitions:
        [(id: Int, position: CGPoint, range: ClosedRange<String>)] = [
            (id: 1, position: CGPoint(x: 0.25, y: 0.11), range: "A"..."E"),
            (id: 2, position: CGPoint(x: 0.75, y: 0.48), range: "F"..."J"),
            (id: 3, position: CGPoint(x: 0.30, y: 0.70), range: "K"..."O"),
            (id: 4, position: CGPoint(x: 0.80, y: 0.92), range: "P"..."T"),
        ]

    @State private var levels: [LevelInfo] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                Image("map-background")  // Make sure this asset exists!
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()  // Extend to screen edges

                // Level Markers
                ForEach(levels) { level in
                    Button {
                        handleLevelTap(level)
                    } label: {
                        levelMarker(level: level)
                    }
                    // Position the center of the button based on relative coordinates
                    .position(
                        x: geometry.size.width * level.position.x,
                        y: geometry.size.height * level.position.y
                    )
                    .disabled(level.status == .locked)  // Disable locked levels
                }

                // Back Button (Top Left)
                VStack {
                    HStack {
                        Button {
                            // Navigate back to the main app view
                            withAnimation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                            ) {
                                appStateManager.currentScreen = .mainApp
                            }
                            // Alternatively, if presented modally: dismiss()
                        } label: {
                            Text("Kembali")
                                .font(.appFont(.rethinkBold, size: 16))
                                .foregroundColor(Color("AppOrange"))
                                .padding(.horizontal, 25)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule().fill(Color.white.opacity(0.95))
                                        .shadow(
                                            color: .black.opacity(0.2),
                                            radius: 3, x: 0, y: 2)
                                )
                        }
                        .padding(.leading)  // Padding from the left edge

                        Spacer()  // Pushes button to the left
                    }
                    Spacer()  // Pushes HStack (and button) to the top
                }
            }
        }
        .onAppear {
            // Calculate level statuses when the view appears
            updateLevelStatuses()
        }
        // Hide the default navigation bar if you were using NavigationView
        // .navigationBarHidden(true)
    }
    
    private func updateLevelStatuses() {
        let progressManager = appStateManager.characterProgress
        // Determine the character the user should be learning next
        let nextCharToLearn = progressManager.getNextCharacterToLearn()  // e.g., "C" if A, B unlocked

        var updatedLevels: [LevelInfo] = []

        for definition in levelDefinitions {
            let levelRange = definition.range
            var status: LevelStatus = .locked  // Default to locked

            // Check if the *first* character of the level is unlocked
            if let firstChar = levelRange.lowerBound.first,
                progressManager.isCharacterUnlocked(String(firstChar))
            {
                // At least the start of the level is unlocked. Now determine if it's current or fully unlocked.
                // If the *next character to learn* is within this level's range, it's the current level.
                if levelRange.contains(nextCharToLearn) {
                    status = .current
                } else {
                    // If the next character to learn is *beyond* this level's range, this level is fully unlocked.
                    // We compare the next character to learn with the *last* character of the level range.
                    // String comparison works alphabetically for single uppercase letters.
                    if nextCharToLearn > levelRange.upperBound {
                        status = .unlocked
                    } else {
                        // This case might occur if nextCharToLearn is before the range starts,
                        // but the first char is unlocked (e.g., user jumped ahead via debug?).
                        // Treat as unlocked or current based on your logic. Let's default to unlocked.
                        status = .unlocked
                        // Or potentially current if any char in range is NOT unlocked? More complex.
                        // Let's stick to the simpler logic for now.
                    }
                }
            } else {
                // First character not unlocked, so the whole level is locked.
                status = .locked
            }

            // Special case: If the user has unlocked Z, mark the last level containing Z as unlocked, not current.
            if nextCharToLearn == "Z"
                && progressManager.isCharacterUnlocked("Z")
                && levelRange.contains("Z")
            {
                status = .unlocked
            }

            updatedLevels.append(
                LevelInfo(
                    id: definition.id,
                    position: definition.position,
                    status: status,
                    characterRange: definition.range
                )
            )
        }
        self.levels = updatedLevels
        print(
            "Updated Level Statuses: \(self.levels.map { "ID: \($0.id) Status: \($0.status)" })"
        )
    }

    // --- Helper View for Level Marker ---
    @ViewBuilder
    private func levelMarker(level: LevelInfo) -> some View {
        ZStack {
            Circle()
                .fill(levelStatusColor(level.status))
                .frame(width: 55, height: 55)  // Adjust size as needed
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

            // Optional: Add an outer ring for 'current' state
            if level.status == .current {
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 62, height: 62)
            }

            Text("\(level.id)")
                .font(.appFont(.dylexicBold, size: 24))  // Use app font
                .foregroundColor(
                    level.status == .locked ? .gray.opacity(0.8) : .white)
        }
        .opacity(level.status == .locked ? 0.7 : 1.0)  // Dim locked levels
    }

    // --- Helper Function for Marker Color ---
    private func levelStatusColor(_ status: LevelStatus) -> Color {
        switch status {
        case .locked:
            return Color.gray.opacity(0.6)
        case .unlocked:
            return Color("AppYellow").opacity(0.9)  // Or another color for unlocked
        case .current:
            return Color.red.opacity(0.9)  // Or your 'current level' color
        }
    }

    // --- Action Handler for Level Tap ---
    private func handleLevelTap(_ level: LevelInfo) {
        guard level.status != .locked else { return }

        print("Tapped Level \(level.id)")

        // --- Navigate based on Level ID ---
        if level.id == 1 {  // Specific action for Level 1
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appStateManager.currentScreen = .characterSelection(
                    levelId: level.id)
            }
        } else {
            // Handle taps for other levels later
            print("Navigation for level \(level.id) not implemented yet.")
        }
    }
}

#Preview {
    // Create a dummy AppStateManager for the preview
    let previewStateManager = AppStateManager()
    // Optionally set the current screen for preview context
    // previewStateManager.currentScreen = .levelMap

    return LevelMapView()
        .environmentObject(previewStateManager)
    // Add a dummy background color if the image asset isn't available in preview easily
    // .background(Color.green.ignoresSafeArea())
}
