//
//  LevelMapView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI

struct LevelMapView: View {
    @StateObject var viewModel: LevelMapViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                Image("map-background") // Ensure this asset exists
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea() // Extend to screen edges

                // Level Markers
                ForEach(viewModel.levels) { level in
                    Button {
                        viewModel.handleLevelTap(level)
                    } label: {
                        levelMarker(level: level, geometry: geometry)
                    }
                    // Position the center of the button based on relative coordinates
                    .position(
                        x: geometry.size.width * level.position.x,
                        y: geometry.size.height * level.position.y
                    )
                    .disabled(level.status == .locked) // Disable locked levels
                }

                // Back Button (Top Left)
                backButton
            }
        }
        .onAppear {
            // ViewModel can update statuses if needed, e.g., if progress could change
            // while this view is not visible but then reappears.
            viewModel.updateLevelStatuses()
        }
        // .navigationBarHidden(true) // If part of a NavigationView and you want to hide it
    }

    // MARK: - Subviews

    private var backButton: some View {
        VStack {
            HStack {
                Button {
                    viewModel.navigateBackToDashboard()
                } label: {
                    Text("Kembali")
                        .navigationStyle(size: 16)
                        .foregroundColor(Color("AppOrange"))
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(
                            Capsule().fill(Color.white.opacity(0.95))
                                .shadow(
                                    color: .black.opacity(0.2),
                                    radius: 3, x: 0, y: 2
                                )
                        )
                }
                .padding([.top, .leading]) // Add top padding as well
                Spacer() // Pushes button to the left
            }
            Spacer() // Pushes HStack (and button) to the top
        }
    }

    // Helper View for Level Marker
    @ViewBuilder
    private func levelMarker(level: LevelInfo, geometry: GeometryProxy) -> some View {
        let markerSize = min(geometry.size.width, geometry.size.height) * 0.12 // Relative size

        ZStack {
            Circle()
                .fill(levelStatusColor(level.status))
                .frame(width: markerSize, height: markerSize)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

            if level.status == .current {
                Circle()
                    .stroke(Color.white, lineWidth: markerSize * 0.06) // Relative stroke
                    .frame(width: markerSize * 1.1, height: markerSize * 1.1) // Slightly larger
            }

            Text("\(level.id)")
                .levelStyle(size: markerSize * 0.4, isBold: true) // Use our new level style
                .foregroundColor(
                    level.status == .locked ? .gray.opacity(0.8) : .white
                )
        }
        .opacity(level.status == .locked ? 0.6 : 1.0) // Dim locked levels more
    }

    // Helper Function for Marker Color
    private func levelStatusColor(_ status: LevelStatus) -> Color {
        switch status {
        case .locked:
            return Color.gray.opacity(0.5) // Darker gray for locked
        case .unlocked:
            return Color("AppYellow").opacity(0.9) // Standard unlocked color
        case .current:
            return Color.red.opacity(0.9) // Bright color for current
        }
    }
}
