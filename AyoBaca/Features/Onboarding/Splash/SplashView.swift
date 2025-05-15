//
//  SplashView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//


import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @State private var animateTitle = false
    @State private var animateMascot = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea()
                
                // Animated floating circles background
                ForEach(0..<6) { index in
                    Circle()
                        .fill(Color.white.opacity(0.07))
                        .frame(width: CGFloat.random(in: 40...120))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .offset(y: animateTitle ? CGFloat.random(in: -30...30) : 0)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: animateTitle
                        )
                }

                VStack(spacing: 10) {
                    VStack(spacing: -50) {
                        Text("AYO")
                            .font(.appFont(.dylexicBold, size: 60))
                            .foregroundColor(.white)
                        Text("BACA")
                            .font(.appFont(.dylexicBold, size: 60))
                            .foregroundColor(.white)
                    }
                    .opacity(animateTitle ? 1 : 0)
                    .offset(y: animateTitle ? 0 : 20)
                    .padding(.vertical, 150)
                    
                    Image("mascot")
                        .scaledToFit()
                        .frame(height: geometry.size.height * 0.6)
                        .scaleEffect(animateMascot ? 1.0 : 0.8)
                        .opacity(animateMascot ? 1.0 : 0)
                        .offset(y: animateMascot ? 0 : 50)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            // Trigger animations when view appears
            withAnimation(.easeOut(duration: 0.8)) {
                animateTitle = true
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                animateMascot = true
            }
            
            // Note: Navigation is now handled by AppStateManager in ContentView
        }
    }
}
