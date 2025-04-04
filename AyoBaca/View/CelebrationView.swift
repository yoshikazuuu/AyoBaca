//
//  CelebrationView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//

import SwiftUI

struct CelebrationView: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var onboardingState: OnboardingState
    
    var body: some View {
        ZStack {
            Color("AppOrange").ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Selamat Datang,")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text(onboardingState.childName)
                    .font(.appFont(.dylexicBold, size: 40))
                    .foregroundColor(.white)
                
                LottieView(name: "celebration")
                    .frame(height: 200)
                
                Text("Petualangan Membaca Dimulai!")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Button {
                    withAnimation {
                        currentScreen = .mainApp
                    }
                } label: {
                    Text("Mulai Sekarang")
                        .fontWeight(.semibold)
                        .foregroundColor(Color("AppOrange"))
                        .padding()
                        .frame(width: 200)
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .padding(.top, 30)
            }
            .onAppear {
                // Auto advance after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        currentScreen = .mainApp
                    }
                }
            }
        }
    }
}

// For Lottie animations, you'll need to add the package and create a wrapper:
struct LottieView: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        // Add Lottie animation here - requires Lottie package
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Update the view
    }
}
