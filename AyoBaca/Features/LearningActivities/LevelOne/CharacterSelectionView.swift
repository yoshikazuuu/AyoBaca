//
//  CharacterSelectionView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 07/04/25.
//

import SwiftUI

struct CharacterSelectionView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    let levelId: Int
    
    // Define the alphabet
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
    
    // Configure grid layout
    let columns: [GridItem] = Array(
        repeating: .init(.flexible(), spacing: 15), count: 4)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Color
                Color("AppOrange").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Back Button
                    HStack {
                        Button {
                            withAnimation {
                                appStateManager.currentScreen = .levelMap
                            }
                        } label: {
                            Text("Kembali")
                                .font(.appFont(.rethinkBold, size: 16))
                                .foregroundColor(Color("AppOrange"))
                                .padding(.horizontal, 25)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule().fill(Color.white.opacity(0.95))
                                        .shadow(
                                            color: .black.opacity(0.2),
                                            radius: 3, x: 0, y: 2)
                                )
                        }
                        .padding(.leading)
                        Spacer()
                    }
                    
                    // Title
                    Text("Pilih Huruf")
                        .font(.appFont(.dylexicBold, size: 28))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    // Grid of Characters
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(alphabet, id: \.self) { character in
                                Button {
                                    appStateManager.setCurrentLearningCharacter(character)

                                    // Navigate to Spelling Activity
                                    withAnimation {
                                        appStateManager.currentScreen =
                                            .spellingActivity(
                                                character: character)
                                    }
                                } label: {
                                    Text(character)
                                        .font(.appFont(.dylexicBold, size: 50))
                                        .foregroundColor(
                                            isCharacterUnlocked(character)
                                            ? Color("AppOrange") : .gray
                                                .opacity(0.5)
                                        )
                                        .frame(maxWidth: .infinity)
                                        .aspectRatio(1, contentMode: .fit)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.white)
                                                .shadow(
                                                    color: .black.opacity(0.15),
                                                    radius: 4, x: 0, y: 2)
                                        )
                                        .overlay(
                                            // Show lock icon for locked characters
                                            Group {
                                                if !isCharacterUnlocked(character) {
                                                    Image(systemName: "lock.fill")
                                                        .foregroundColor(.gray.opacity(0.5))
                                                        .font(.system(size: 24))
                                                }
                                            }
                                        )
                                }
                                .disabled(!isCharacterUnlocked(character))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // Helper to determine if a character is unlocked
    func isCharacterUnlocked(_ character: String) -> Bool {
        return appStateManager.characterProgress.isCharacterUnlocked(character)
    }
}


#Preview {
    CharacterSelectionView(levelId: 1)
        .environmentObject(AppStateManager()) // Provide dummy state manager
}
