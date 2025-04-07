//
//  WritingView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 07/04/25.
//


// Features/LearningActivities/Writing/Views/WritingView.swift

import SwiftUI

struct WritingView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    let character: String
    
    // State for drawing paths
    @State private var drawingPaths: [DrawingPath] = []
    // State for showing unlock celebration
    @State private var showUnlockCelebration = false
    @State private var unlockedCharacter = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Color
                Color(red: 0.8, green: 0.9, blue: 1.0).ignoresSafeArea()
                
                VStack(spacing: 15) {
                    // Instruction Text
                    Text("Gambar Huruf Dikotak")
                        .font(.appFont(.rethinkBold, size: 24))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.top, geometry.safeAreaInsets.top + 30)
                    
                    // Drawing Area Box
                    ZStack {
                        // Background with dashed border
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .strokeBorder(
                                        style: StrokeStyle(
                                            lineWidth: 4, dash: [10, 8])
                                    )
                                    .foregroundColor(Color("AppOrange").opacity(0.5))
                            )
                        
                        // Drawing Canvas
                        DrawingCanvas(
                            paths: $drawingPaths,
                            canvasColor: .clear,
                            drawingColor: .black,
                            lineWidth: 8.0
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        
                        // Display the target character
                        Text(character)
                            .font(.appFont(.dylexicRegular, size: 200))
                            .foregroundColor(.gray.opacity(0.15))
                            .allowsHitTesting(false)
                        
                    }
                    .padding(.horizontal, 40)
                    .aspectRatio(1, contentMode: .fit)
                    
                    // Action Buttons
                    HStack(spacing: 20) {
                        Button {
                            drawingPaths.removeAll()
                        } label: {
                            Label("Ulangi", systemImage: "trash")
                                .font(.appFont(.rethinkBold, size: 16))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule().fill(Color.white)
                                        .shadow(radius: 3)
                                )
                        }
                        
                        Button {
                            // Check if next character exists to unlock
                            if let nextChar = appStateManager.characterProgress.getNextCharacter(after: character) {
                                // Unlock the next character
                                appStateManager.characterProgress.unlockCharacter(nextChar)
                                unlockedCharacter = nextChar
                                showUnlockCelebration = true
                                
                                // Show celebration, then navigate after delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    withAnimation {
                                        // Return to character selection to see new unlock
                                        appStateManager.currentScreen = .characterSelection(levelId: 1)
                                        showUnlockCelebration = false
                                    }
                                }
                            } else {
                                // No more characters to unlock, just go back to map
                                withAnimation {
                                    appStateManager.currentScreen = .levelMap
                                }
                            }
                        } label: {
                            Label("Selesai", systemImage: "checkmark.circle.fill")
                                .font(.appFont(.rethinkBold, size: 16))
                                .foregroundColor(.green)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule().fill(Color.white)
                                        .shadow(radius: 3)
                                )
                        }
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                    
                    // Mascot Image
                    Image("mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 0.5)
                }
                .frame(width: geometry.size.width)
                
                // Back Button
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                appStateManager.currentScreen = .spellingActivity(character: character)
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.title2.weight(.semibold))
                                .padding(12)
                                .background(Color.white.opacity(0.7))
                                .foregroundColor(Color("AppOrange"))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .padding(.leading)
                        Spacer()
                    }
                    Spacer()
                }
                
                // Unlock celebration overlay
                if showUnlockCelebration {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Text("Huruf Baru Terbuka!")
                                .font(.appFont(.dylexicBold, size: 28))
                                .foregroundColor(.white)
                            
                            Text(unlockedCharacter)
                                .font(.appFont(.dylexicBold, size: 120))
                                .foregroundColor(Color("AppYellow"))
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 180, height: 180)
                                )
                            
                            // Show confetti effect
                            ConfettiView()
                                .allowsHitTesting(false)
                                .frame(height: 200)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}


#Preview {
    WritingView(character: "A")
        .environmentObject(AppStateManager())
}
