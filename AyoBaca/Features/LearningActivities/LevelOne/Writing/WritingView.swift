//
//  WritingView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI

struct WritingView: View {
    @StateObject var viewModel: WritingViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.8, green: 0.9, blue: 1.0).ignoresSafeArea()

                VStack(spacing: 15) {
                    instructionText.padding(
                        .top, geometry.safeAreaInsets.top + 20)

                    drawingArea(geometry: geometry)
                        .padding(.horizontal, 20)
                        .aspectRatio(1, contentMode: .fit) // Maintain square aspect ratio

                    controlsHStack
                        .padding(.top, 5)

                    Spacer()
                    mascotImage(geometry: geometry)
                        .padding(
                            .bottom,
                            geometry.safeAreaInsets.bottom > 0 ? 0 : 20)
                }
                .frame(width: geometry.size.width)
                .alert(
                    "Validasi Huruf", isPresented: $viewModel.showValidationAlert
                ) {
                    Button("Ok", role: .cancel) {}
                } message: {
                    Text(viewModel.validationMessage)
                }

                backButton

                if viewModel.showUnlockCelebration {
                    unlockCelebrationOverlay
                }
            }
        }
        .onAppear {
            // Reset drawing if view appears, e.g. navigating back then forward
            // viewModel.clearDrawing() // Or handle this based on specific needs
        }
    }

    private var instructionText: some View {
        Text(viewModel.instructionText)
            .font(.appFont(.rethinkBold, size: 22))
            .foregroundColor(.black.opacity(0.7))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    private func drawingArea(geometry: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            Color("AppOrange").opacity(0.5),
                            style: StrokeStyle(lineWidth: 3, dash: [8, 6])
                        )
                )

            // Ghost character
            Text(viewModel.targetCharacter)
                .font(.appFont(
                    .dylexicRegular, size: geometry.size.width * 0.6)) // Responsive ghost size
                .foregroundColor(.gray.opacity(0.10)) // Slightly less visible
                .allowsHitTesting(false)

            DrawingCanvas(
                paths: $viewModel.drawingPaths,
                currentPath: $viewModel.currentDrawingPath,
                canvasColor: .clear,
                drawingColor: viewModel.currentDrawingPath.color,
                lineWidth: viewModel.currentDrawingPath.lineWidth
            )
            .clipShape(RoundedRectangle(cornerRadius: 20)) // Clip drawing to the bounds
        }
    }

    private var controlsHStack: some View {
        HStack(spacing: 20) {
            Button { viewModel.clearDrawing() } label: {
                Label("Ulangi", systemImage: "trash")
                    .font(.appFont(.rethinkBold, size: 16))
                    .foregroundColor(Color.red.opacity(0.8))
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Capsule().fill(Color.white).shadow(
                        color: .black.opacity(0.1), radius: 3, x: 0, y: 1))
            }
            Button { viewModel.submitDrawing() } label: {
                Label("Selesai", systemImage: "checkmark.circle.fill")
                    .font(.appFont(.rethinkBold, size: 16))
                    .foregroundColor(Color.green.opacity(0.9))
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Capsule().fill(Color.white).shadow(
                        color: .black.opacity(0.1), radius: 3, x: 0, y: 1))
            }
        }
    }

    private func mascotImage(geometry: GeometryProxy) -> some View {
        Image("mascot")
            .resizable()
            .scaledToFit()
            .frame(height: geometry.size.height * 0.20) // Slightly smaller
            .allowsHitTesting(false)
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


    private var unlockCelebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea() // Slightly more opaque
                .onTapGesture {
                    viewModel.celebrationDismissed()
                }
            
            ConfettiView().allowsHitTesting(false)
                .frame(height: 350) // Larger confetti area
                .offset(y: -60)

            VStack(spacing: 20) {
                Text("Hebat!")
                    .font(.appFont(.dylexicBold, size: 36)) // Larger
                    .foregroundColor(.white)

                Text("Kamu berhasil menulis huruf")
                    .font(.appFont(.rethinkRegular, size: 20))
                    .foregroundColor(.white.opacity(0.9))

                Text(viewModel.unlockedCharacterDisplay)
                    .font(.appFont(.dylexicBold, size: 130)) // Larger
                    .foregroundColor(Color("AppYellow"))
                    .padding()
                    .background(
                        Circle().fill(Color.white.opacity(0.15))
                            .frame(width: 200, height: 200) // Larger circle
                    )
                    .shadow(color: Color("AppYellow").opacity(0.5), radius: 10)

                Text("Ayo lanjut ke huruf berikutnya!")
                    .font(.appFont(.rethinkBold, size: 18)) // Bolder
                    .foregroundColor(.white)
                    .padding(.top, 10)

            }
            .padding()
            .scaleEffect(viewModel.showUnlockCelebration ? 1 : 0.8) // Scale effect
            .opacity(viewModel.showUnlockCelebration ? 1 : 0)
            .onAppear {
                // Auto-dismiss handled by ViewModel to ensure state consistency
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    viewModel.celebrationDismissed()
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.showUnlockCelebration)
    }
}
