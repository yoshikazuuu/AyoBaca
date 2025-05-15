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
                    instructionText.padding(.top, geometry.safeAreaInsets.top + 20)
                    
                    if viewModel.debugMode {
                        debugStatusText
                    }

                    drawingArea(geometry: geometry) // Pass geometry for potential aspect ratio use
                        .padding(.horizontal, 20) // Adjusted padding
                        .aspectRatio(1, contentMode: .fit)


                    controlsHStack
                        .padding(.top, 5)

                    if viewModel.debugMode {
                        debugControlsHStack.padding(.top, 5)
                    }
                    
                    Spacer()
                    mascotImage(geometry: geometry)
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 20) // Adjust padding if no home indicator
                }
                .frame(width: geometry.size.width)
                .alert("Validasi Huruf", isPresented: $viewModel.showValidationAlert) {
                    Button("Ok", role: .cancel) {}
                } message: {
                    Text(viewModel.validationMessage)
                }

                backButton(geometry: geometry)

                if viewModel.showUnlockCelebration {
                    unlockCelebrationOverlay
                }
                
                if viewModel.showDebugImage, let uiImage = viewModel.debugUIImage {
                    debugImageOverlay(uiImage: uiImage)
                }
            }
        }
    }

    private var instructionText: some View {
        Text(viewModel.instructionText) // Use dynamic instruction text
            .font(.appFont(.rethinkBold, size: 22))
            .foregroundColor(.black.opacity(0.7))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    private var debugStatusText: some View {
        Text("Target: \(viewModel.targetCharacter) | Paths: \(viewModel.drawingPaths.count)")
            .font(.caption)
            .foregroundColor(.black.opacity(0.6))
            .padding(.horizontal)
    }

    // Pass geometry to drawingArea if it needs to make decisions based on available space
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

            DrawingCanvas(
                paths: $viewModel.drawingPaths,
                currentPath: $viewModel.currentDrawingPath,
                canvasColor: .clear, // Canvas itself is clear
                drawingColor: viewModel.currentDrawingPath.color, // Use color from current path
                lineWidth: viewModel.currentDrawingPath.lineWidth  // Use lineWidth from current path
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Text(viewModel.targetCharacter)
                .font(.appFont(.dylexicRegular, size: geometry.size.width * 0.5)) // Responsive ghost size
                .foregroundColor(.gray.opacity(0.12))
                .allowsHitTesting(false)
        }
    }

    private var controlsHStack: some View {
        HStack(spacing: 20) {
            Button { viewModel.clearDrawing() } label: {
                Label("Ulangi", systemImage: "trash")
                    .font(.appFont(.rethinkBold, size: 16))
                    .foregroundColor(.red)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Capsule().fill(Color.white).shadow(radius: 3))
            }
            Button { viewModel.submitDrawing() } label: {
                Label("Selesai", systemImage: "checkmark.circle.fill")
                    .font(.appFont(.rethinkBold, size: 16))
                    .foregroundColor(.green)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Capsule().fill(Color.white).shadow(radius: 3))
            }
        }
    }
    
    private var debugControlsHStack: some View {
        HStack(spacing: 15) {
            Button("Debug Img") {
                // Pass a reasonable size for the debug image
                viewModel.generateProcessedImageFromPaths(targetSize: CGSize(width:280, height:280))
            }
            .font(.appFont(.rethinkRegular, size: 14))
            .padding(8).background(Color.blue.opacity(0.7)).foregroundColor(.white).cornerRadius(8)

            Button("Force OK") {
                viewModel.forceSuccessAndProceed()
            }
            .font(.appFont(.rethinkRegular, size: 14))
            .padding(8).background(Color.purple.opacity(0.7)).foregroundColor(.white).cornerRadius(8)
            
            Toggle("Debug Mode", isOn: $viewModel.debugMode)
                .font(.appFont(.rethinkRegular, size: 12))
                .foregroundColor(.white) // Adjust color for visibility
        }
        .padding(.horizontal)
    }

    private func mascotImage(geometry: GeometryProxy) -> some View {
        Image("mascot")
            .resizable()
            .scaledToFit()
            .frame(height: geometry.size.height * 0.22) // Slightly adjusted
            .allowsHitTesting(false)
    }
    
    private func backButton(geometry: GeometryProxy) -> some View {
        VStack {
            HStack {
                Button { viewModel.navigateBackToCharacterSelection() } label: {
                    Image(systemName: "arrow.left")
                        .font(.title2.weight(.semibold))
                        .padding(12)
                        .background(Color.white.opacity(0.7))
                        .foregroundColor(Color("AppOrange"))
                        .clipShape(Circle()).shadow(radius: 3)
                }
                // Use safeAreaInsets for padding if available, otherwise a fixed value
                .padding(.top, geometry.safeAreaInsets.top > 0 ? geometry.safeAreaInsets.top : 10)
                .padding(.leading)
                Spacer()
            }
            Spacer()
        }
    }

    private var unlockCelebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
                .onTapGesture {
                    // viewModel.showUnlockCelebration = false // Simple dismiss
                    viewModel.celebrationDismissed() // Dismiss and navigate
                }

            VStack(spacing: 20) {
                Text("Hebat!") // Changed title
                    .font(.appFont(.dylexicBold, size: 32))
                    .foregroundColor(.white)
                
                Text("Kamu berhasil menulis huruf")
                    .font(.appFont(.rethinkRegular, size: 20))
                    .foregroundColor(.white)

                Text(viewModel.unlockedCharacterDisplay) // Character just completed
                    .font(.appFont(.dylexicBold, size: 120))
                    .foregroundColor(Color("AppYellow"))
                    .padding()
                    .background(
                        Circle().fill(Color.white.opacity(0.2))
                            .frame(width: 180, height: 180) // Ensure circle is large enough
                    )
                
                Text("Ayo lanjut ke huruf berikutnya!")
                     .font(.appFont(.rethinkRegular, size: 18))
                     .foregroundColor(.white)
                     .padding(.top, 10)

                // Confetti should be part of this overlay if it's specific to this celebration
                ConfettiView().allowsHitTesting(false)
                    .frame(height: 300) // Adjust size as needed
                    .offset(y: -50) // Adjust position to spread out more
            }
            .padding()
            .onAppear {
                // Auto-dismiss after a few seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    if viewModel.showUnlockCelebration { // Check if still showing
                        viewModel.celebrationDismissed()
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private func debugImageOverlay(uiImage: UIImage) -> some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
                .onTapGesture { viewModel.showDebugImage = false }

            VStack(spacing: 15) {
                Text("Processed Image for Analysis")
                    .font(.headline).foregroundColor(.white)
                
                Image(uiImage: uiImage)
                    .resizable().scaledToFit()
                    .background(Color.white)
                    .border(Color.gray, width: 1)
                    .frame(maxWidth: 300, maxHeight: 300)

                Button("Close") { viewModel.showDebugImage = false }
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Color.blue).foregroundColor(.white).cornerRadius(8)
            }
            .padding()
        }
    }
}
