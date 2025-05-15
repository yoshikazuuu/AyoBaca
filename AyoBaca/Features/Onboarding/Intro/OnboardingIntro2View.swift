//
//  OnboardingIntro2View.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI

struct OnboardingIntro2View: View {
    @StateObject var viewModel: OnboardingIntroViewModel
    // @EnvironmentObject var onboardingState: OnboardingState // If needed

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background for Intro2 (specific blue)
                // This is now handled by ContentView's ZStack background logic
                // Color(red: 0.6, green: 0.8, blue: 1.0).ignoresSafeArea()
                Image("onboarding2") // Ensure this asset exists
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    // Mascot is part of this background image.
                    // If separate:
                    // .offset(y: viewModel.animateMascot ? 0 : 100)
                    // .opacity(viewModel.animateMascot ? 1 : 0)

                VStack { // Main content VStack
                    Spacer()
                    speechBubbleWithButton
                        .opacity(viewModel.animateBubble ? 1 : 0)
                        .scaleEffect(viewModel.animateBubble ? 1 : 0.8)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.onAppearIntro2()
        }
    }

    private var speechBubbleWithButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            Color("AppOrange").opacity(0.5),
                            style: StrokeStyle(lineWidth: 3, dash: [8, 6])
                        )
                )
                .frame(width: 330, height: 280) // Adjusted height

            VStack(alignment: .center, spacing: 20) { // Increased spacing
                Text(
                    "Tapi sebelumnya, aku mau kenalin dulu tombol-tombol yang akan kamu pakai selama petualangan seru ini! Yuk, kita lihat bersama!"
                )
                .font(.appFont(.dylexicRegular, size: 18)) // Slightly larger
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.8))
                .lineSpacing(5)

                // Start Button
                Button {
                    viewModel.finalizeOnboardingAndNavigateToMainApp()
                } label: {
                    Text("Klik untuk Mulai")
                        .font(.appFont(.dylexicBold, size: 17)) // Bolder
                        .foregroundColor(.white)
                        .padding(.vertical, 14) // Slightly taller
                        .padding(.horizontal, 35) // Slightly wider
                        .background(Color("AppYellow"))
                        .cornerRadius(30) // More rounded
                        .shadow(
                            color: Color.black.opacity(0.2),
                            radius: 4, x: 0, y: 2
                        )
                }
                .padding(.top, 10)
                .opacity(viewModel.animateButton ? 1 : 0)
                .scaleEffect(viewModel.animateButton ? 1 : 0.9)
            }
            .padding(EdgeInsets(top: 25, leading: 25, bottom: 30, trailing: 25))
        }
        .padding(.horizontal, 30)
    }
}
