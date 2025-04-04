//
//  AgeSetupView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//


import SwiftUI

struct AgeSetupView: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var onboardingState: OnboardingState
    @State private var animateTitle = false
    @State private var animateAgeSelector = false
    @State private var animateContinueButton = false
    @State private var animateMascot = false
    @State private var showConfetti = false
    
    // Expanded age range from 1 to 15
    let ages = Array(1...15)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea()
                
                FloatingAlphabetBackground(count: 25, fontStyle: .dylexicRegular)
                
                VStack(spacing: 20) {
                    // Back button row
                    HStack {
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                currentScreen = .nameSetup
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(.white.opacity(0.2)))
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Title
                    Text("Umur Anak")
                        .font(.appFont(.rethinkExtraBold, size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(animateTitle ? 1 : 0)
                        .offset(y: animateTitle ? 0 : 20)
                    
                    // Scrollable age selector
                    VStack {
                        Text("Pilih umur:")
                            .foregroundColor(.white)
                            .font(.appFont(.rethinkRegular, size: 24))
                            .opacity(animateAgeSelector ? 1 : 0)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(ages, id: \.self) { age in
                                    Button {
                                        withAnimation(.spring(response: 0.4)) {
                                            onboardingState.childAge = age
                                            showConfetti = true
                                        }
                                        
                                        // Show continue button after selection
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                                            animateContinueButton = true
                                        }
                                    } label: {
                                        Text("\(age)")
                                            .font(.system(size: 30, weight: .bold))
                                            .frame(width: 65, height: 65)
                                            .foregroundColor(
                                                onboardingState.childAge == age
                                                ? .white
                                                : Color("AppOrange")
                                            )
                                            .background(
                                                onboardingState.childAge == age
                                                ? Color("AppOrange").opacity(0.7)
                                                : Color.white
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(
                                                        onboardingState.childAge == age
                                                        ? Color.white
                                                        : Color.clear,
                                                        lineWidth: 2
                                                    )
                                            )
                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                            .scaleEffect(onboardingState.childAge == age ? 1.1 : 1.0)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.vertical, 5)
                                    .scaleEffect(animateAgeSelector ? 1 : 0.5)
                                    .opacity(animateAgeSelector ? 1 : 0)
                                    .animation(
                                        .spring(response: 0.5)
                                        .delay(0.1 + Double(age - 1) * 0.03),
                                        value: animateAgeSelector
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 70)
                        }
                        .padding(.vertical, 5)
                    }
                    .frame(width: geometry.size.width)
                    
                    // Continue button appears after selection
                    if animateContinueButton || onboardingState.childAge != nil {
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                currentScreen = .mainApp
                            }
                        } label: {
                            Text("Mulai Petualangan!")
                                .fontWeight(.semibold)
                                .foregroundColor(Color("AppOrange"))
                                .padding()
                                .frame(width: 200)
                                .background(Color.white)
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        }
                        .padding(.top, 10)
                        .scaleEffect(animateContinueButton ? 1 : 0.8)
                        .opacity(animateContinueButton ? 1 : 0)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Progress indicator
                    OnboardingProgressView(currentStep: 3, totalSteps: 4)
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    // Mascot and speech bubble
                    ZStack(alignment: .top) {
                        // Speech bubble only shows when mascot is animated
                        if animateMascot {
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
                        
                        // Mascot image
                        Image("mascot")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 1)
                            .offset(y: animateMascot ? 0 : 150)
                            .opacity(animateMascot ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                }
                .padding(.vertical, 10)
                .frame(width: geometry.size.width) // Constrain to screen width
                
                // Confetti effect when age is selected
                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .opacity(0.7)
                        .onAppear {
                            // Hide confetti after a delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showConfetti = false
                                }
                            }
                        }
                }
            }
        }
        .onAppear {
            // Sequence the animations
            withAnimation(.easeOut(duration: 0.5)) {
                animateTitle = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateAgeSelector = true
            }
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.3)) {
                animateMascot = true
            }
            
            // If age was already selected (coming back from next screen)
            if onboardingState.childAge != nil {
                withAnimation {
                    animateContinueButton = true
                }
            }
        }
    }
}

// Improved confetti view (contained)
struct ConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    @State private var confetti: [ConfettiPiece] = []
    
    struct ConfettiPiece: Identifiable {
        let id = UUID()
        let color: Color
        var position: CGPoint
        let rotation: Double
        let scale: CGFloat
        var opacity: Double = 1.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confetti) { piece in
                    Rectangle()
                        .fill(piece.color)
                        .frame(width: 8, height: 8)
                        .position(x: piece.position.x, y: piece.position.y)
                        .rotationEffect(.degrees(piece.rotation))
                        .scaleEffect(piece.scale)
                        .opacity(piece.opacity)
                }
            }
            .onAppear {
                generateConfetti(count: 50, in: geometry.size)
            }
        }
    }
    
    func generateConfetti(count: Int, in size: CGSize) {
        for _ in 0..<count {
            let piece = ConfettiPiece(
                color: colors.randomElement()!,
                position: CGPoint(
                    x: CGFloat.random(in: 50...(size.width - 50)),
                    y: CGFloat.random(in: 50...200)
                ),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.5)
            )
            confetti.append(piece)
        }
        
        // Animate confetti falling and fading
        withAnimation(.linear(duration: 2.0)) {
            for i in 0..<confetti.count {
                let yOffset = CGFloat.random(in: 200...400)
                confetti[i].position.y += yOffset
                confetti[i].opacity = 0
            }
        }
    }
}

#Preview {
    AgeSetupView(currentScreen: .constant(.nameSetup))
        .environmentObject(OnboardingState())
}
