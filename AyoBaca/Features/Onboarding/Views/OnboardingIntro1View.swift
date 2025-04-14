//
//  OnboardingIntro1View.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 14/04/25.
//


// OnboardingIntro1View.swift
import SwiftUI

struct OnboardingIntro1View: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @EnvironmentObject var onboardingState: OnboardingState // Get child's name

    @State private var animateBubble = false
    @State private var animateMascot = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) { // Ensure ZStack centers its content
                // Background
                Image("onboarding1")  // Make sure this asset exists!
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
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
                                    .foregroundColor(Color("AppOrange").opacity(0.6))
                            )
                            .frame(width: 330, height: 350)

                        // Text Content
                        VStack(alignment: .center, spacing: 10) {
                            Text("Halo, \(appStateManager.userProfile?.childName ?? "Anak")! Selamat datang di AYO BACA!")
                                .font(
                                    .appFont(.dylexicBold, size: 18)
                                ) // Use your app font
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black.opacity(0.8))

                            Text("Aku **ADO**, teman belajarmu! Yuk kita mulai petualangan seru belajar membaca, sampai kamu jadi Master Membaca!")
                                .font(
                                    .appFont(.dylexicRegular, size: 16)
                                ) // Use your app font
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black.opacity(0.7))
                                .lineSpacing(4)

                        }
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 25, trailing: 20)) // Adjust padding

                    }
                    .padding(.horizontal, 30)
                    .opacity(animateBubble ? 1 : 0)
                    .scaleEffect(animateBubble ? 1 : 0.8)
                    .onTapGesture { // Navigate on tap
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            appStateManager.currentScreen = .onboardingIntro2
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Center the VStack
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
