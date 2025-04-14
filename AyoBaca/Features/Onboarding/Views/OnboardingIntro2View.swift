// OnboardingIntro2View.swift
import SwiftUI

struct OnboardingIntro2View: View {
    @EnvironmentObject var appStateManager: AppStateManager

    @State private var animateBubble = false
    @State private var animateMascot = false
    @State private var animateButton = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.6, green: 0.8, blue: 1.0) // Light blue background
                    .ignoresSafeArea()

                // Optional: Add cloud assets
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
                                    .foregroundColor(Color("AppOrange").opacity(0.6))
                            )

                        // Text Content
                        VStack(alignment: .center, spacing: 15) { // Increased spacing
                             // Speaker Icon
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title)
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.bottom, 5)

                            Text("Tapi sebelumnya, aku mau kenalin dulu tombol-tombol yang akan kamu pakai selama petualangan seru ini! Yuk, kita lihat bersama!")
                                .font(.appFont(.rethinkRegular, size: 17)) // Use your app font
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black.opacity(0.8))
                                .lineSpacing(5) // Adjust line spacing

                            // Start Button
                            Button {
                                // Finalize onboarding and navigate to Main App
                                appStateManager.finalizeOnboarding()
                            } label: {
                                Text("Klik untuk Mulai")
                                    .font(.appFont(.rethinkBold, size: 16))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 30)
                                    .background(Color("AppYellow")) // Use your yellow color
                                    .cornerRadius(25)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            .padding(.top, 10) // Add padding above button
                            .opacity(animateButton ? 1 : 0)
                            .scaleEffect(animateButton ? 1 : 0.9)

                        }
                        .padding(EdgeInsets(top: 25, leading: 20, bottom: 25, trailing: 20))

                    }
                    .padding(.horizontal, 30)
                    .opacity(animateBubble ? 1 : 0)
                    .scaleEffect(animateBubble ? 1 : 0.8)


                     // Progress Indicator
                    OnboardingProgressView(currentStep: 5, totalSteps: 5) // Step 5 of 5
                        .padding(.top, 30)

                    Spacer() // Pushes mascot down

                    // Mascot (different expression?)
                    Image("mascot_wink") // Use a different mascot image if available, otherwise use the default
                        .resizable()
                        .scaledToFit()
                        .frame(height: geometry.size.height * 0.4) // Adjust size
                        .opacity(animateMascot ? 1 : 0)
                        .offset(y: animateMascot ? 0 : 50)

                }
                 .padding(.bottom, -geometry.safeAreaInsets.bottom)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2)) {
                animateBubble = true
            }
             withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                animateButton = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4)) {
                animateMascot = true
            }
        }
    }
}

#Preview {
    OnboardingIntro2View()
        .environmentObject(AppStateManager())
}
