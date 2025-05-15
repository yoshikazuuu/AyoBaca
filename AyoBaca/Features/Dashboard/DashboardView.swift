//
//  DashboardView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI
import SwiftData // Only if @Query is used directly, otherwise remove
import TipKit

struct DashboardView: View {
    // ViewModel now manages the state and logic for this view.
    @StateObject var viewModel: DashboardViewModel
    // The @Query for readingActivities was not used in the original MainAppView's body.
    // If it's not needed, it can be removed. If the ViewModel needs it,
    // ModelContext would be injected into the ViewModel.
    // @Environment(\.modelContext) private var modelContext
    // @Query private var readingActivities: [ReadingActivity]

    var body: some View {
        ZStack {
            // Background
            Color("AppOrange").ignoresSafeArea()
            FloatingAlphabetBackground(
                count: 25, fontStyle: .dylexicRegular
            ).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    // Profile card
                    profileCard
                        .popoverTip(
                            viewModel.mainTips.currentTip as? ProfileTip,
                            arrowEdge: .top
                        )
                        .padding(.top) // Padding from notch area

                    // Mascot and streak card
                    mascotStreakCard
                        .popoverTip(
                            viewModel.mainTips.currentTip as? MascotAndStreakTip,
                            arrowEdge: .top
                        )

                    // Start Practice Button
                    startPracticeButton
                        .popoverTip(
                            viewModel.mainTips.currentTip as? PracticeButtonTip,
                            arrowEdge: .top
                        )

                    // Bottom navigation
                    bottomNavigation
                        // Tips for bottom buttons are applied individually
                        .padding(.bottom) // Padding from home indicator
                }
                .padding(.vertical) // Overall vertical padding for ScrollView content
            }
        }
        // Task for TipKit configuration can remain here or be in the App's init.
        // Since it's global, App's init is fine.
        // .task {
        //     #if DEBUG
        //         // try? Tips.resetDatastore() // For testing, show tips every time
        //     #endif
        //     // try? Tips.configure([
        //     //     .displayFrequency(.immediate),
        //     //     .datastoreLocation(.applicationDefault),
        //     // ])
        //     // print("TipKit configured for DashboardView")
        // }
    }

    // MARK: - UI Components (Subviews)

    private var profileCard: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .trim(from: 0, to: 1) // Full circle
                    .rotation(Angle(degrees: 0)) // No animation needed for static fill
                    .fill(Color.yellow.opacity(0.5))
                    .frame(width: 100, height: 100)

                Image("mascot") // Ensure asset exists
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }
            .frame(width: 100, height: 100) // Consistent frame for the ZStack

            VStack(alignment: .leading, spacing: 4) { // Adjusted spacing
                Text(viewModel.childName)
                    .font(.appFont(.dylexicBold, size: 20))
                    .foregroundColor(Color("AppOrange"))

                Text("\(viewModel.childAge) tahun")
                    .font(.appFont(.dylexicBold, size: 16))
                    .foregroundColor(Color("AppOrange").opacity(0.8))

                Text("LV 3 Master") // This seems static, or could be from ViewModel
                    .font(.appFont(.dylexicBold, size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("AppOrange").opacity(0.8))
                    .cornerRadius(20) // Capsule shape
            }
            Spacer() // Pushes content to the left
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 25)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        .padding(.horizontal) // Padding outside the card for spacing from screen edges
    }

    private var mascotStreakCard: some View {
        ZStack(alignment: .top) { // Align streak counter to the top
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)

            VStack(spacing: 0) { // VStack for mascot image
                Image("mascot-streak") // Ensure asset exists
                    .resizable()
                    .scaledToFit()
                    // .clipShape(RoundedRectangle(cornerRadius: 20)) // Clipping if image itself isn't rounded
                    .padding(20) // Padding around the image inside the card
            }

            // Streak Counter Badge
            HStack(spacing: 6) { // Increased spacing for readability
                Image(systemName: "flame.fill")
                    .foregroundColor(
                        viewModel.currentStreak > 0
                            ? .orange : .gray.opacity(0.7)
                    )
                Text("\(viewModel.currentStreak) Hari Beruntun")
            }
            .font(.appFont(.dylexicBold, size: 14))
            .foregroundColor(viewModel.currentStreak > 0 ? .black : .gray) // Adjust text color
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.yellow.opacity(0.9))
                    .shadow(
                        color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2
                    )
            )
            .offset(y: -18) // Position badge overlapping the top edge
        }
        .frame(height: 380) // Adjusted height
        .padding(.horizontal) // Padding outside the card
    }

    private var startPracticeButton: some View {
        Button {
            viewModel.startPracticeTapped()
        } label: {
            Text("Mulai Latihan")
                .font(.appFont(.dylexicBold, size: 18)) // Increased size
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color("AppYellow"))
                .cornerRadius(30) // Fully rounded ends
                .shadow(
                    color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4
                )
        }
        .padding(.horizontal, 50) // Horizontal padding for the button itself
    }

    private var bottomNavigation: some View {
        HStack {
            navigationButton(
                systemImage: "location.fill",
                accessibilityLabel: "Peta Baca",
                tip: viewModel.mainTips.currentTip as? MapButtonTip,
                action: viewModel.mapButtonTapped
            )
            Spacer()
            navigationButton(
                systemImage: "person.fill",
                accessibilityLabel: "Profil Pengguna",
                tip: viewModel.mainTips.currentTip as? ProfileButtonTip,
                action: viewModel.profileButtonTapped
            )
        }
        .padding(.horizontal, 40) // Padding for the HStack
    }

    // Helper for creating navigation buttons to reduce repetition
    private func navigationButton<T: Tip>(
        systemImage: String,
        accessibilityLabel: String,
        tip: T?,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .medium)) // Slightly larger icon
                .foregroundColor(Color("AppOrange"))
                .frame(width: 55, height: 55) // Larger tap area
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 4, x: 0, y: 2
                        )
                )
        }
        .accessibilityLabel(Text(accessibilityLabel))
        .popoverTip(tip, arrowEdge: .top) // Apply tip if available
    }
}