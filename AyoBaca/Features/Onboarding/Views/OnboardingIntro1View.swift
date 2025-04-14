// OnboardingIntro1View.swift
import SwiftUI

struct OnboardingIntro1View: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @EnvironmentObject var onboardingState: OnboardingState // Get child's name

    @State private var animateBubble = false
    @State private var animateMascot = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.6, green: 0.8, blue: 1.0) // Light blue background
                    .ignoresSafeArea()

                // Optional: Add cloud assets if you have them
                Image("cloud_asset_1") // Replace with your asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.5)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.15)
                    .opacity(0.8)
                Image("cloud_asset_2") // Replace with your asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.4)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.7)
                    .opacity(0.7)


                VStack {
                    Spacer() // Push content down

                    // Speech Bubble
                    ZStack {
                        // Bubble Shape
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: 3, dash: [10, 5])
                                    )
                                    .foregroundColor(Color("AppOrange").opacity(0.6)) // Use your app color
                            )

                        // Text Content
                        VStack(alignment: .center, spacing: 10) {
                             // Speaker Icon
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title)
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.bottom, 5)

                            Text("Halo, \(appStateManager.userProfile?.childName ?? "Anak")! Selamat datang di AYO BACA!")
                                .font(.appFont(.rethinkBold, size: 18)) // Use your app font
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black.opacity(0.8))

                            Text("Aku **ADO**, teman belajarmu! Yuk kita mulai petualangan seru belajar membaca, sampai kamu jadi Master Membaca!")
                                .font(.appFont(.rethinkRegular, size: 16)) // Use your app font
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black.opacity(0.7))
                                .lineSpacing(4)

                        }
                        .padding(EdgeInsets(top: 25, leading: 20, bottom: 25, trailing: 20)) // Adjust padding

                    }
                    .padding(.horizontal, 30)
                    .opacity(animateBubble ? 1 : 0)
                    .scaleEffect(animateBubble ? 1 : 0.8)
                    .onTapGesture { // Navigate on tap
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            appStateManager.currentScreen = .onboardingIntro2
                        }
                    }


                    // Progress Indicator
                    OnboardingProgressView(currentStep: 4, totalSteps: 5) // Step 4 of 5
                        .padding(.top, 30)


                    Spacer() // Pushes mascot down

                    // Mascot
                    Image("mascot") // Use your mascot asset
                        .resizable()
                        .scaledToFit()
                        .frame(height: geometry.size.height * 0.4) // Adjust size as needed
                        .opacity(animateMascot ? 1 : 0)
                        .offset(y: animateMascot ? 0 : 50)

                }
                .padding(.bottom, -geometry.safeAreaInsets.bottom) // Allow mascot to go edge-to-edge at bottom
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2)) {
                animateBubble = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4)) {
                animateMascot = true
            }
        }
    }
}

#Preview {
    // Create dummy data for preview
    let previewStateManager = AppStateManager()
    previewStateManager.userProfile = UserProfile(childName: "Budi", childAge: 7)

    return OnboardingIntro1View()
        .environmentObject(previewStateManager)
        .environmentObject(OnboardingState()) // Add if needed by subviews
}
