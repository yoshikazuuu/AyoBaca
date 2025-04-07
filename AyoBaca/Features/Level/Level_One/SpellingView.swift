//
//  SpellingView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 07/04/25.
//


// Features/LearningActivities/Spelling/Views/SpellingView.swift

import SwiftUI

struct SpellingView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    let character: String

    // State for animation or interaction feedback
    @State private var isMicActive = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Color
                Color(red: 0.8, green: 0.9, blue: 1.0).ignoresSafeArea() // Light blue

                VStack {
                    // Instruction Text
                    Text("Bunyikan Huruf Ini!")
                        .font(.appFont(.rethinkBold, size: 24))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.top, geometry.safeAreaInsets.top + 30)

                    Spacer()

                    // Character Display Box
                    ZStack {
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
                            .padding(.horizontal, 40)
                            .aspectRatio(1, contentMode: .fit) // Make it square

                        Text(character)
                            .font(.appFont(.dylexicBold, size: 180)) // Large OpenDyslexic
                            .foregroundColor(Color("AppOrange"))
                    }

                    Spacer()

                    // Microphone Button
                    Button {
                        // --- Placeholder Action ---
                        // TODO: Implement actual speech recognition logic
                        print("Mic button tapped for \(character)")
                        isMicActive.toggle() // Simple feedback

                        // Simulate success and navigate after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                appStateManager.currentScreen =
                                    .writingActivity(character: character)
                            }
                            isMicActive = false // Reset mic state
                        }
                        // --- End Placeholder ---

                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 30))
                            .foregroundColor(
                                isMicActive ? .red : Color("AppOrange"))
                            .frame(width: 70, height: 70)
                            .background(
                                Circle().fill(Color.white)
                                    .shadow(
                                        color: .black.opacity(0.2), radius: 5,
                                        x: 0, y: 3)
                            )
                    }
                    .padding(.bottom, 20)

                    
                    // Mascot image
                    Image("mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 0.5)
                }
                .frame(width: geometry.size.width)

                // Optional Back Button (Top Left) - Add if desired
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                // Go back to character selection for the *same* level
                                appStateManager.currentScreen =
                                    .characterSelection(levelId: 1) // Assuming level 1
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
            }
        }
    }
}

#Preview {
    SpellingView(character: "A")
        .environmentObject(AppStateManager())
}
