//
//  OnboardingIntro1View.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI

struct OnboardingIntro1View: View {
    @StateObject var viewModel: OnboardingIntroViewModel
    // If mascot animation is globally shared via OnboardingState, keep this.
    // Otherwise, viewModel.animateMascot can drive it.
    // @EnvironmentObject var onboardingState: OnboardingState

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Background for Intro1 (specific blue)
                // This is now handled by ContentView's ZStack background logic
                // Color(red: 0.6, green: 0.8, blue: 1.0).ignoresSafeArea()
                Image("onboarding1") // Ensure this asset exists
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    // The mascot is part of the background image here.
                    // If it were a separate element, its animation would be:
                    // .offset(y: viewModel.animateMascot ? 0 : 100)
                    // .opacity(viewModel.animateMascot ? 1 : 0)


                VStack { // Main content VStack
                    Spacer() // Pushes bubble towards center/bottom

                    // Speech Bubble
                    speechBubble
                        .opacity(viewModel.animateBubble ? 1 : 0)
                        .scaleEffect(viewModel.animateBubble ? 1 : 0.8)
                        .onTapGesture { // Navigate on tap
                            viewModel.navigateToOnboardingIntro2()
                        }
                    
                    Spacer() // Pushes bubble towards center/top
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.onAppearIntro1()
        }
    }

    private var speechBubble: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .strokeBorder(
                            Color("AppOrange").opacity(0.6),
                            style: StrokeStyle(lineWidth: 3, dash: [10, 5])
                        )
                )
                .frame(width: 330, height: 380)

            VStack(alignment: .center, spacing: 15) { // Increased spacing
                Text(
                    "Halo, \(viewModel.childName)! Selamat datang di AYO BACA!"
                )
                .font(.appFont(.dylexicBold, size: 20)) // Slightly larger
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.85))

                Text(
                    "Aku **ADO**, teman belajarmu! Yuk kita mulai petualangan seru belajar membaca, sampai kamu jadi Master Membaca!"
                )
                .font(.appFont(.dylexicRegular, size: 17)) // Slightly larger
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.75))
                .lineSpacing(5)
            }
            .padding(EdgeInsets(top: 25, leading: 25, bottom: 30, trailing: 25))
        }
        .padding(.horizontal, 30) // Padding for the ZStack containing the bubble
    }
}
