//
//  SplashView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

import SwiftUI

struct SplashView: View {
    @StateObject var viewModel: SplashViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea()

                ForEach(0..<6) { index in
                    Circle()
                        .fill(Color.white.opacity(0.07))
                        .frame(width: CGFloat.random(in: 40...120))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height))
                        .offset(
                            y: viewModel.animateTitle
                                ? CGFloat.random(in: -30...30) : 0)
                        .animation(
                            Animation.easeInOut(
                                duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: viewModel.animateTitle)
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
                    .opacity(viewModel.animateTitle ? 1 : 0)
                    .offset(y: viewModel.animateTitle ? 0 : 20)
                    .padding(.vertical, 150)

                    Image("mascot")
                        .scaledToFit()
                        .frame(height: geometry.size.height * 0.6)
                        .scaleEffect(viewModel.animateMascot ? 1.0 : 0.8)
                        .opacity(viewModel.animateMascot ? 1.0 : 0)
                        .offset(y: viewModel.animateMascot ? 0 : 50)
                }
                .frame(
                    width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}
