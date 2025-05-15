//
//  AgeSetupView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI

struct AgeSetupView: View {
    @StateObject var viewModel: AgeSetupViewModel
    @EnvironmentObject var onboardingState: OnboardingState // For mascot image animation

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea()
                FloatingAlphabetBackground(
                    count: 25, fontStyle: .dylexicRegular
                )

                VStack(spacing: 20) {
                    backButtonRow
                    Spacer()
                    titleText
                    ageSelectorScrollView(geometry: geometry)

                    if viewModel.animateContinueButton
                        || viewModel.onboardingState.childAge != nil
                    {
                        continueButton
                    }

                    OnboardingProgressView(currentStep: 3, totalSteps: 4)
                        .padding(.top, 10)
                    Spacer()
                    mascotAndBubble(geometry: geometry)
                }
                .padding(.vertical, 10)
                .frame(width: geometry.size.width)

                if viewModel.showConfetti {
                    ConfettiView() // Ensure this view is correctly implemented
                        .allowsHitTesting(false)
                        .opacity(0.7)
                        // Confetti hiding is managed by the ViewModel
                }
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    // MARK: - Subviews
    private var backButtonRow: some View {
        HStack {
            Button { viewModel.navigateBack() } label: {
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

    private var titleText: some View {
        Text("Umur Anak")
            .font(.appFont(.rethinkExtraBold, size: 32))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .opacity(viewModel.animateTitle ? 1 : 0)
            .offset(y: viewModel.animateTitle ? 0 : 20)
    }

    private func ageSelectorScrollView(geometry: GeometryProxy) -> some View {
        VStack {
            Text("Pilih umur:")
                .foregroundColor(.white)
                .font(.appFont(.rethinkRegular, size: 24))
                .opacity(viewModel.animateAgeSelector ? 1 : 0)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.ages, id: \.self) { age in
                        ageButton(age: age)
                            .scaleEffect(viewModel.animateAgeSelector ? 1 : 0.5)
                            .opacity(viewModel.animateAgeSelector ? 1 : 0)
                            .animation(
                                .spring(response: 0.5)
                                    .delay(
                                        0.1 + Double(age - viewModel.ages.first!)
                                            * 0.03
                                    ), // Staggered animation
                                value: viewModel.animateAgeSelector
                            )
                    }
                }
                .padding(.horizontal, 20) // Padding for the HStack content
                .frame(height: 100) // Ensure enough height for scaled buttons
            }
            .padding(.vertical, 5)
        }
        .frame(width: geometry.size.width) // Ensure VStack takes full width
    }

    private func ageButton(age: Int) -> some View {
        Button {
            viewModel.selectAge(age)
        } label: {
            Text("\(age)")
                .font(.system(size: 30, weight: .bold))
                .frame(width: 65, height: 65)
                .foregroundColor(
                    viewModel.onboardingState.childAge == age
                        ? .white : Color("AppOrange")
                )
                .background(
                    viewModel.onboardingState.childAge == age
                        ? Color("AppOrange").opacity(0.7) : Color.white
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            viewModel.onboardingState.childAge == age
                                ? Color.white : Color.clear,
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2
                )
        }
        .buttonStyle(PlainButtonStyle()) // Removes default button styling
        .scaleEffect(
            viewModel.onboardingState.childAge == age ? 1.1 : 1.0
        ) // Scale effect for selected age
    }

    private var continueButton: some View {
        Button {
            viewModel.continueToNextStep()
        } label: {
            Text("Mulai Petualangan!")
                .fontWeight(.semibold)
                .foregroundColor(Color("AppOrange"))
                .padding()
                .frame(minWidth: 220) // Ensure button has good width
                .background(Color.white)
                .cornerRadius(25)
                .shadow(
                    color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3
                )
        }
        .padding(.top, 10)
        .scaleEffect(viewModel.animateContinueButton ? 1 : 0.8)
        .opacity(viewModel.animateContinueButton ? 1 : 0)
        .transition(.scale.combined(with: .opacity))
    }

    private func mascotAndBubble(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            if viewModel.animateMascotSpeechBubble {
                Text("Berapa umurmu?")
                    .font(.appFont(.rethinkRegular, size: 16))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(15)
                    .offset(y: -60)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }

            Image("mascot")
                .resizable()
                .scaledToFit()
                .frame(
                    width: geometry.size.width * 0.8,
                    height: geometry.size.height * 0.35
                )
                .offset(y: onboardingState.animateMascot ? 0 : 100)
                .opacity(onboardingState.animateMascot ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
    }
}
