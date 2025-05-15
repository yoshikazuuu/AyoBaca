//
//  NameSetupView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI

struct NameSetupView: View {
    @StateObject var viewModel: NameSetupViewModel
    // The OnboardingState is observed by the ViewModel, but if the View
    // directly uses its properties (like animateMascot), it needs it too.
    @EnvironmentObject var onboardingState: OnboardingState
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea()
                    .onTapGesture { isTextFieldFocused = false } // Dismiss keyboard

                FloatingAlphabetBackground(
                    count: 25, fontStyle: .dylexicRegular
                )

                VStack(spacing: 20) {
                    // Back button row
                    backButtonRow

                    Spacer()

                    // Title
                    Text("Nama Anak")
                        .font(.appFont(.rethinkExtraBold, size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(viewModel.animateTitle ? 1 : 0)
                        .offset(y: viewModel.animateTitle ? 0 : 20)

                    // Name input field
                    nameTextField

                    // Next button
                    nextButton

                    // Progress indicator
                    OnboardingProgressView(currentStep: 2, totalSteps: 4)
                        .padding(.top, 10)

                    Spacer()

                    // Mascot and speech bubble
                    mascotAndBubble(geometry: geometry)
                }
                .padding(.vertical, 10)
                .frame(width: geometry.size.width)
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
            // Auto focus the text field slightly delayed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isTextFieldFocused = true
            }
        }
    }

    // MARK: - Subviews

    private var backButtonRow: some View {
        HStack {
            Button {
                isTextFieldFocused = false // Dismiss keyboard on back
                viewModel.navigateBack()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color.white.opacity(0.2)))
            }
            .padding(.leading, 20)
            Spacer()
        }
        .padding(.top, 10)
    }

    private var nameTextField: some View {
        // Bind directly to the OnboardingState's childName via the ViewModel's reference
        TextField(
            "Masukkan Nama Disini",
            text: $viewModel.onboardingState.childName
        )
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(25)
        .foregroundColor(Color("AppOrange")) // Text color
        .accentColor(Color("AppOrange")) // Cursor color
        .multilineTextAlignment(.center)
        .font(.appFont(.rethinkBold, size: 24))
        .focused($isTextFieldFocused)
        .submitLabel(.done)
        .onSubmit {
            isTextFieldFocused = false
            if !viewModel.onboardingState.childName.isEmpty {
                viewModel.continueToAgeSetup() // Optionally navigate on submit
            }
        }
        .frame(height: 60)
        .padding(.horizontal, 40)
        .scaleEffect(viewModel.animateTextField ? 1 : 0.8)
        .opacity(viewModel.animateTextField ? 1 : 0)
    }

    private var nextButton: some View {
        Button {
            isTextFieldFocused = false // Dismiss keyboard
            viewModel.continueToAgeSetup()
        } label: {
            Text("Lanjut")
                .font(.appFont(.rethinkRegular, size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color("AppOrange"))
                .padding()
                .frame(width: 150)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(
                    color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3
                )
        }
        .opacity(
            viewModel.onboardingState.childName.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
                ? 0.5 : 1.0
        )
        .disabled(
            viewModel.onboardingState.childName.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
        )
        .scaleEffect(viewModel.animateButton ? 1 : 0.8)
        .opacity(viewModel.animateButton ? 1 : 0)
    }

    private func mascotAndBubble(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            // Speech bubble controlled by NameSetupViewModel
            if viewModel.animateMascotSpeechBubble {
                Text("Siapa nama kamu?")
                    .font(.appFont(.rethinkRegular, size: 16))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(
                        color: .black.opacity(0.1), radius: 3, x: 0, y: 2
                    )
                    .offset(y: -60) // Position above mascot
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }

            // Mascot image animation driven by shared OnboardingState
            Image("mascot") // Ensure asset exists
                .resizable()
                .scaledToFit()
                .frame(
                    width: geometry.size.width * 0.8, // Adjusted size
                    height: geometry.size.height * 0.35 // Adjusted size
                )
                 // Use the corrected animateMascot property
                .offset(y: onboardingState.animateMascot ? 0 : 100)
                .opacity(onboardingState.animateMascot ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20) // Ensure it doesn't overlap bottom elements too much
    }
}
