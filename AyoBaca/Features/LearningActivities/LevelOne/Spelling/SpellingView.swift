//
//  SpellingView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI

struct SpellingView: View {
    @StateObject var viewModel: SpellingViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.8, green: 0.9, blue: 1.0).ignoresSafeArea()

                VStack {
                    instructionText.padding(.top, geometry.safeAreaInsets.top + 20)
                    Spacer()
                    characterDisplayBox
                    Spacer()

                    if !viewModel.showFeedback {
                        micButtonAndInstruction
                    } else {
                        feedbackContainer(geometry: geometry)
                    }
                }
                .frame(width: geometry.size.width)
                // Consistent padding at the bottom, considering safe area
                .padding(.bottom, geometry.safeAreaInsets.bottom + (viewModel.showFeedback ? 0 : 20))


                backButton
                
                if viewModel.isCorrectPronunciation && viewModel.showFeedback {
                    ConfettiView().allowsHitTesting(false)
                        // .frame(height: 200) // Adjust frame as needed
                }
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
        .onDisappear {
            // Ensure resources are cleaned up if the view disappears unexpectedly
            // viewModel.stopRecording(processed: true) // Or a more specific cleanup method
        }
    }

    // MARK: - Subviews
    private var instructionText: some View {
        Text("Bunyikan Huruf Ini!")
            .font(.appFont(.rethinkBold, size: 24))
            .foregroundColor(Color.black.opacity(0.7))
    }

    private var characterDisplayBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            Color("AppOrange").opacity(0.5),
                            style: StrokeStyle(lineWidth: 3, dash: [8, 6])
                        )
                )
                .padding(.horizontal, 40)
                .aspectRatio(1, contentMode: .fit)

            Text(viewModel.character)
                .font(.appFont(.dylexicBold, size: 180))
                .foregroundColor(Color("AppOrange"))
                .scaleEffect(viewModel.pulseEffect ? 1.1 : 1.0)
                .animation(
                    viewModel.pulseEffect
                        ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                        : .default,
                    value: viewModel.pulseEffect
                )
        }
        .padding(.bottom, 20)
    }

    private var micButtonAndInstruction: some View {
        VStack(spacing: 10) {
            Button {
                viewModel.toggleRecording()
            } label: {
                Image(systemName: viewModel.isMicActive ? "mic.fill" : "mic")
                    .font(.system(size: 30))
                    .foregroundColor(viewModel.isMicActive ? .red : Color("AppOrange"))
                    .frame(width: 70, height: 70)
                    .background(
                        Circle().fill(Color.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                    )
                    .overlay(
                        Circle()
                            .stroke(viewModel.isMicActive ? Color.red : Color.clear, lineWidth: 3)
                            .scaleEffect(viewModel.pulseEffect && viewModel.isMicActive ? 1.2 : 1.0)
                            .opacity(viewModel.pulseEffect && viewModel.isMicActive ? 0 : 1)
                            .animation(
                                viewModel.isMicActive
                                    ? Animation.easeOut(duration: 1).repeatForever(autoreverses: false)
                                    : .default,
                                value: viewModel.pulseEffect // Animate based on pulseEffect
                            )
                    )
            }

            Text(
                viewModel.isMicActive
                    ? "Silakan ucapkan huruf \(viewModel.character)..."
                    : "Tekan tombol mikrofon untuk mulai"
            )
            .font(.appFont(.rethinkRegular, size: 16))
            .foregroundColor(Color.black.opacity(0.6))
        }
        .padding(.bottom, 10) // Original padding
    }

    private func feedbackContainer(geometry: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)

            VStack(spacing: 12) {
                Text(
                    viewModel.isCorrectPronunciation
                        ? "Bagus Sekali! 👏" : "Coba Lagi Ya! 💪"
                )
                .font(.appFont(.rethinkBold, size: 22))
                .foregroundColor(viewModel.isCorrectPronunciation ? .green : Color("AppOrange"))
                .padding(.top, 16)

                Text(viewModel.feedbackMessage)
                    .font(.appFont(.rethinkRegular, size: 16))
                    .foregroundColor(Color.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                if viewModel.showTip {
                    tipView
                }

                if !viewModel.isCorrectPronunciation {
                    retryButton.padding(.bottom, 16) // Ensure padding at the bottom of the button
                }
            }
            .padding(.vertical, 4) // Original padding
            .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
        }
        .frame(width: geometry.size.width - 40)
        // Removed padding from here, applied to parent VStack's bottom
    }

    private var tipView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color("AppOrange"))
                    .padding(.top, 2)
                Text("Tip: " + viewModel.getTipForCharacter())
                    .font(.appFont(.rethinkRegular, size: 14))
                    .foregroundColor(Color.black)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }

    private var retryButton: some View {
        Button {
            // ViewModel handles resetting feedback and starting recording
            viewModel.toggleRecording() // Or a specific retry function
        } label: {
            Text("Coba Lagi Ya! 💪") // Consistent text
                .font(.appFont(.rethinkBold, size: 18))
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color("AppOrange"))
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.top, 8)
    }
    
    private var backButton: some View {
        VStack {
            HStack {
                Button {
                    viewModel.navigateBackToCharacterSelection()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title2.weight(.semibold))
                        .padding(12)
                        .background(Color.white.opacity(0.7))
                        .foregroundColor(Color("AppOrange"))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .padding([.top, .leading]) // Add top padding
                Spacer()
            }
            Spacer()
        }
    }
}
