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
}

struct LevelMapView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @Environment(\.dismiss) var dismiss  // Alternative way to go back if needed

    // --- Level Data ---
    // Adjust positions (x, y) based on your background image layout
    // (0,0) is top-left, (1,1) is bottom-right
    @State private var levels: [LevelInfo] = [
        LevelInfo(id: 1, position: CGPoint(x: 0.25, y: 0.11), status: .current),  // Example: Start at level 1
        LevelInfo(id: 2, position: CGPoint(x: 0.75, y: 0.48), status: .locked),
        LevelInfo(id: 3, position: CGPoint(x: 0.30, y: 0.70), status: .locked),
        LevelInfo(id: 4, position: CGPoint(x: 0.80, y: 0.92), status: .locked),
        // Add more levels as needed
    ]

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
        // Hide the default navigation bar if you were using NavigationView
        // .navigationBarHidden(true)
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
