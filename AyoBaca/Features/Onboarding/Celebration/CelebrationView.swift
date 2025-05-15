//
//  CelebrationView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI

struct CelebrationView: View {
    // The binding to currentScreen is removed; ViewModel handles navigation.
    @StateObject var viewModel: CelebrationViewModel

    var body: some View {
        ZStack {
            Color("AppOrange").ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Selamat Datang,")
                    .font(.largeTitle) // Consider .appFont if available
                    .foregroundColor(.white)

                Text(viewModel.childNameDisplay)
                    .font(.appFont(.dylexicBold, size: 40))
                    .foregroundColor(.white)

                LottieView(name: "celebration") // Ensure LottieView is correctly implemented
                    .frame(height: 250) // Adjusted size

                Text("Petualangan Membaca Dimulai!")
                    .font(.title2) // Consider .appFont
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Button {
                    viewModel.navigateToMainApp()
                } label: {
                    Text("Mulai Sekarang")
                        .fontWeight(.semibold)
                        .foregroundColor(Color("AppOrange"))
                        .padding()
                        .frame(minWidth: 200) // Ensure good tap area
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .padding(.top, 30)
            }
            .padding() // Add some padding to the VStack
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}