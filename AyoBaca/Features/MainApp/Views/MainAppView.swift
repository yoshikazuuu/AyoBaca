// MainAppView.swift
import SwiftData
import SwiftUI
import TipKit

struct MainAppView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @Environment(\.modelContext) private var modelContext
    @Query private var readingActivities: [ReadingActivity]

    // TipGroup for sequential display
    @State private var mainTips = TipGroup(.ordered) {
        ProfileTip()
        StreakTip()
        MascotTip()
        PracticeButtonTip()
    }

    var body: some View {
        ZStack {
            // Background (Stays edge-to-edge)
            Color("AppOrange").ignoresSafeArea()
            FloatingAlphabetBackground(
                count: 25, fontStyle: .dylexicRegular
            )
            .ignoresSafeArea()  // Ensure background ignores safe area

            // --- Wrap main content in ScrollView to respect safe areas ---
            ScrollView {
                VStack(spacing: 30) {
                    // Profile card
                    profileCard
                        .cornerRadius(15)
                        .popoverTip(
                            mainTips.currentTip as? ProfileTip, arrowEdge: .top
                        )
                        // Add some top padding *within* the scroll view
                        // to push content down from the notch area slightly
                        .padding(.top)  // <-- Added Padding

                    // Mascot card
                    mascotStreakCard
                        .popoverTip(
                            mainTips.currentTip as? MascotTip, arrowEdge: .top)

                    // Start Practice Button
                    Button {
                        print("Start practice tapped")
                        // Invalidate tip if needed
                        if let tip = mainTips.currentTip as? PracticeButtonTip {
                            tip.invalidate(reason: .actionPerformed)
                        }
                        // --- Navigate to Level Map ---
                        withAnimation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                        ) {
                            appStateManager.currentScreen = .levelMap
                        }
                        // --- End Navigation ---
                    } label: {
                        Text("Mulai Latihan")
                            .font(.appFont(.dylexicBold, size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color("AppYellow"))
                            .cornerRadius(30)
                            .shadow(
                                color: Color.black.opacity(0.2), radius: 6,
                                x: 0, y: 4
                            )
                            .padding(.horizontal, 50)
                    }
                    .popoverTip(
                        mainTips.currentTip as? PracticeButtonTip,
                        arrowEdge: .top)

                    // Bottom navigation (now part of the scrollable content)
                    HStack {
                        Button {
                            print("Location tapped")
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color("AppOrange"))
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .shadow(
                                            color: Color.black.opacity(0.15),
                                            radius: 4, x: 0, y: 2)
                                )
                        }
                        .accessibilityLabel("Lokasi")

                        Spacer()

                        Button {
                            // Navigate to profile view
                            withAnimation(
                                .spring(response: 0.6, dampingFraction: 0.7)
                            ) {
                                appStateManager.currentScreen = .profile
                            }
                        } label: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color("AppOrange"))
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .shadow(
                                            color: Color.black.opacity(0.15),
                                            radius: 4, x: 0, y: 2)
                                )
                        }
                        .accessibilityLabel("Profil")
                    }
                    .padding(.horizontal, 40)
                    // Add some bottom padding *within* the scroll view
                    // to ensure space above the home indicator area
                    .padding(.bottom)  // <-- Added Padding

                }  // End Main VStack
            }  // --- End ScrollView ---

        }
        // No .onAppear needed specifically for starting the TipKit sequence
    }

    // MARK: - Components (Unchanged)

    var profileCard: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .rotation(Angle(degrees: 360))
                    .fill(Color.yellow.opacity(0.5))
                    .frame(width: 100, height: 100)

                Image("mascot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }
            .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: 0) {
                Text(appStateManager.userProfile?.childName ?? "MARVIN")
                    .font(.appFont(.dylexicBold, size: 20))
                    .foregroundColor(Color("AppOrange"))

                Text("\(appStateManager.userProfile?.childAge ?? 7) tahun")
                    .font(.appFont(.dylexicBold, size: 16))
                    .foregroundColor(Color("AppOrange").opacity(0.8))

                Text("LV 3 Master")
                    .font(.appFont(.dylexicBold, size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("AppOrange").opacity(0.8))
                    .cornerRadius(20)
            }

            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 25)
        .background(Color.white)
        .cornerRadius(25)  // Keep corner radius on the card background
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        .padding(.horizontal)  // Padding outside the card
    }

    var mascotStreakCard: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)

            VStack(spacing: 0) {
                Image("mascot-streak")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(20)
            }

            Text("0 Streak")
                .font(.appFont(.dylexicBold, size: 14))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.yellow.opacity(0.9))
                        .shadow(
                            color: Color.black.opacity(0.2), radius: 4, x: 0,
                            y: 2)
                )
                .offset(y: -15)
                // --- Attach popover tip for Streak ---
                // Note: This tip is attached to the ZStack containing the mascot
                // If you want it specifically on the badge, attach it there.
                .popoverTip(mainTips.currentTip as? StreakTip, arrowEdge: .top)
        }
        .frame(height: 400)
        .padding(.horizontal)
    }

    // --- Optional: Function to clear user data (if needed for reset) ---
    #if DEBUG
        @MainActor  // Ensure it runs on the main thread for UI/Data updates
        private func clearUserData() async {
            // Example: Delete UserProfile from SwiftData
            do {
                try modelContext.delete(model: UserProfile.self)
                print("DEBUG: Cleared UserProfile data.")
                // You might need to delete other related data too
            } catch {
                print("DEBUG: Failed to clear UserProfile data: \(error)")
            }
        }
    #endif

}

// Preview provider (remains the same)
#Preview {
    let appStateManager = AppStateManager()
    // appStateManager.userProfile = UserProfile(childName: "Budi Preview", childAge: 7)

    return MainAppView()
        .environmentObject(appStateManager)
        .modelContainer(AppModelContainer.preview)
        .task {
            #if DEBUG
                try? Tips.resetDatastore()
            #endif
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault),
            ])
            print("TipKit configured for Preview")
        }
}
