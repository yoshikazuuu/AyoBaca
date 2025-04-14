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
        MascotAndStreakTip()
        PracticeButtonTip()
        MapButtonTip()
        ProfileButtonTip()
    }

    var body: some View {
        ZStack {
            // Background (Stays edge-to-edge)
            Color("AppOrange").ignoresSafeArea()
            FloatingAlphabetBackground(
                count: 25, fontStyle: .dylexicRegular
            )
            .ignoresSafeArea()  // Ensure background ignores safe area

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
                        .padding(.top)
                    
                    // Mascot card
                    mascotStreakCard
                        .popoverTip(
                            mainTips.currentTip as? MascotAndStreakTip, arrowEdge: .top)
                    
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
                    
                    // Bottom navigation 
                    HStack {
                        Button {
                            withAnimation(
                                .spring(response: 0.6, dampingFraction: 0.7)
                            ) {
                                appStateManager.currentScreen = .levelMap
                            }
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
                        .popoverTip(
                            mainTips.currentTip as? MapButtonTip,
                            arrowEdge: .top
                        )
                        
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
                        .popoverTip(
                            mainTips.currentTip as? ProfileButtonTip,
                            arrowEdge: .top
                        )
                    }
                    .padding(.horizontal, 40)
                    // Add some bottom padding *within* the scroll view
                    // to ensure space above the home indicator area
                    .padding(.bottom)
                    
                }
            }

        }
    }

    // MARK: - Components

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

            HStack(spacing: 4) {  
                Image(systemName: "flame.fill")  
                    .foregroundColor(
                        appStateManager.currentStreak > 0
                            ? .orange : .gray.opacity(0.7)
                    )  
                Text("\(appStateManager.currentStreak) Hari Beruntun")  
            }
            .font(.appFont(.dylexicBold, size: 14))
            .foregroundColor(.black)
            .padding(.horizontal, 16)  
            .padding(.vertical, 8)  
            .background(
                Capsule()  
                    .fill(Color.yellow.opacity(0.9))
                    .shadow(
                        color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
            .offset(y: -18)
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
