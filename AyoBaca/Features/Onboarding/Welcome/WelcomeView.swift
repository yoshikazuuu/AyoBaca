//
//  WelcomeView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI

struct WelcomeView: View {
    @StateObject var viewModel: WelcomeViewModel
    @EnvironmentObject var onboardingState: OnboardingState // For mascot animation

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea()
                FloatingAlphabetBackground(
                    count: 25, fontStyle: .dylexicRegular)

                VStack(spacing: 0) {
                    VStack(spacing: -30) {
                        Text("AYO")
                            .font(.appFont(.dylexicBold, size: 40))
                            .foregroundColor(.white)
                        Text("BACA")
                            .font(.appFont(.dylexicBold, size: 40))
                            .foregroundColor(.white)
                    }
                    .opacity(viewModel.animateTitle ? 1 : 0)
                    .offset(y: viewModel.animateTitle ? 0 : 30)

                    Text("Halo, Ayah dan Bunda!")
                        .font(.appFont(.rethinkBold, size: 24))
                        .foregroundColor(.white)
                        .opacity(viewModel.animateText ? 1 : 0)
                        .offset(y: viewModel.animateText ? 0 : 20)

                    Text(
                        "Aplikasi ini dirancang khusus untuk anak-anak dengan kesulitan membaca agar mereka lebih percaya diri dan semangat belajar."
                    )
                    .font(.appFont(.rethinkRegular, size: 17))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(viewModel.animateText ? 1 : 0)
                    .offset(y: viewModel.animateText ? 0 : 20)

                    Button {
                        viewModel.continueToProfileSetup()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Lanjut ke")
                                .font(.appFont(.rethinkBold, size: 16))
                            Text("Profile Set-up")
                                .font(.appFont(.rethinkItalic, size: 16))
                        }
                        .foregroundColor(Color("AppOrange"))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 5, x: 0, y: 3)
                    }
                    .padding(.top, 30)
                    .scaleEffect(viewModel.animateButton ? 1 : 0.8)
                    .opacity(viewModel.animateButton ? 1 : 0)

                    OnboardingProgressView(currentStep: 1, totalSteps: 4)

                    Image("mascot-hi")
                        .scaledToFit()
                        .frame(height: geometry.size.height * 0.45)
                        .offset(
                            x: onboardingState.animateMascot ? -10 : -100,
                            y: 150)
                        .opacity(onboardingState.animateMascot ? 1 : 0)
                }
                .frame(
                    width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            viewModel.onAppearActions(onboardingState: onboardingState)
        }
    }
}
