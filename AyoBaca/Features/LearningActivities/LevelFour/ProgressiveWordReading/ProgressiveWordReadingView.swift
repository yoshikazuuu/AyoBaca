//
//  ProgressiveWordReadingView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 16/05/25.
//


// ./Features/LearningActivities/LevelFour/ProgressiveWordReading/ProgressiveWordReadingView.swift
// View for the Progressive Word Reading Activity (Level 4)

import SwiftUI

struct ProgressiveWordReadingView: View {
    @StateObject var viewModel: ProgressiveWordReadingViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color from the image (lavender/purple)
                Color(red: 0.65, green: 0.6, blue: 0.85).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    headerButtons
                    instructionBubble(geometry: geometry)
                    wordDisplayContainer(geometry: geometry)
                    progressBar(geometry: geometry)
                    Spacer(minLength: geometry.size.height * 0.05) // Fixed spacer
                    bottomControlsAndMascot(geometry: geometry)
                }
                .padding()
                
                if viewModel.showCompletionAnimation {
                    ConfettiView().allowsHitTesting(false)
                }
            }
        }
        .onAppear {
            // ViewModel can have an onAppear method if needed for initial setup
            // For now, init handles it.
        }
    }

    // MARK: - Subviews
    private var headerButtons: some View {
        HStack {
            Button {
                viewModel.navigateBack()
            } label: {
                Text("Kembali")
                    .navigationStyle(size: 16)
                    .foregroundColor(Color.purple.opacity(0.8))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
            }
            Spacer()
            Button {
                viewModel.playFullWordSound()
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.white.opacity(0.25)))
            }
        }
    }
    
    private func instructionBubble(geometry: GeometryProxy) -> some View {
        ZStack {
            // Background and decoration
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.orange.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [6,4]))
                )
            
            // Text content
            Text(viewModel.instructionText)
                .levelStyle(size: 18)
                .foregroundColor(Color.black.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
        }
        .frame(height: geometry.size.height * 0.15) // Fixed height
        .padding(.horizontal, 10)
        .animation(.easeInOut(duration: 0.3), value: viewModel.instructionText)
    }
    
    private func wordDisplayContainer(geometry: GeometryProxy) -> some View {
        ZStack {
            // Empty background to maintain consistent height
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.clear)
            
            Text(viewModel.attributedWordDisplay)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
                .padding(.horizontal, 10)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .animation(.easeInOut, value: viewModel.attributedWordDisplay)
                .id("wordDisplay-\(viewModel.currentWordIndex)") // Use ID to prevent layout shift
        }
        .frame(height: geometry.size.height * 0.18) // Fixed height
    }

    private func progressBar(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(height: 30)

            Capsule()
                .fill(Color.orange)
                .frame(width: max(0, (geometry.size.width - 60) * CGFloat(viewModel.progress)), height: 30)
        }
        .frame(height: 30)
        .padding(.horizontal, 30)
        .animation(.linear, value: viewModel.progress)
    }
    
    private func bottomControlsAndMascot(geometry: GeometryProxy) -> some View {
        ZStack {
            // Mascot image - positioned absolutely
            VStack {
                Spacer()
                Image("mascot")
                    .resizable()
                    .scaledToFit()
                    .frame(height: geometry.size.height * 0.35)
                    .padding(.bottom)
            }
            
            // Stepper control - positioned relatively to ensure it stays in the same place
            VStack {
                Button {
                    viewModel.advanceHighlight()
                } label: {
                    Image(systemName: "line.horizontal.3")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.black.opacity(0.6))
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        )
                }
                .disabled(viewModel.currentWord == nil)
                .padding(.bottom, geometry.size.height * 0.22)
                
                Spacer()
            }
        }
        .frame(height: geometry.size.height * 0.38) // Fixed container height
    }
}

// Preview
#if DEBUG
struct ProgressiveWordReadingView_Previews: PreviewProvider {
    static var previews: some View {
        let appStateManager = AppStateManager()
        let levelDef = LevelDefinition(
            id: 4,
            position: .zero,
            range: "SENTENCE"..."SENTENCE", // Placeholder
            name: "Sungai Cerita"
        )
        ProgressiveWordReadingView(
            viewModel: ProgressiveWordReadingViewModel(
                appStateManager: appStateManager,
                levelDefinition: levelDef
            )
        )
    }
}
#endif
