//
//  OnboardingIntro2View.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 14/04/25.
//


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
                Image("onboarding2")  // Make sure this asset exists!
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
                            .frame(width: 330, height: 400)

                        // Text Content
                        VStack(alignment: .center, spacing: 15) { // Increased spacing
                            Text("Tapi sebelumnya, aku mau kenalin dulu tombol-tombol yang akan kamu pakai selama petualangan seru ini! Yuk, kita lihat bersama!")
                                .font(
                                    .appFont(.dylexicRegular, size: 17)
                                ) // Use your app font
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black.opacity(0.8))
                                .lineSpacing(5) // Adjust line spacing

                            // Start Button
                            Button {
                                // Finalize onboarding and navigate to Main App
                                appStateManager.finalizeOnboarding()
                            } label: {
                                Text("Klik untuk Mulai")
                                    .font(.appFont(.dylexicRegular, size: 16))
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
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 25, trailing: 20))

                    }
                    .padding(.horizontal, 30)
                    .opacity(animateBubble ? 1 : 0)
                    .scaleEffect(animateBubble ? 1 : 0.8)
                }
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
