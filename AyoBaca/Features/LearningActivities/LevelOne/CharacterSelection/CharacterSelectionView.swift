//
//  CharacterSelectionView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI

struct CharacterSelectionView: View {
    @StateObject var viewModel: CharacterSelectionViewModel

    private let columns: [GridItem] = Array(
        repeating: .init(.flexible(), spacing: 15), count: 4
    )

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea()

                VStack(spacing: 15) {
                    headerRow
                    characterGrid
                }
                .padding(.top, geometry.safeAreaInsets.top + 10)
                .padding(.horizontal)
            }
        }
        .onAppear {
            // It's good practice for the ViewModel to handle its onAppear logic
            viewModel.onAppear()
        }
    }

    private var headerRow: some View {
        VStack(spacing: 5) {
            HStack {
                Button {
                    viewModel.navigateBackToLevelMap()
                } label: {
                    Text("Kembali")
                        .font(.appFont(.rethinkBold, size: 16))
                        .foregroundColor(Color("AppOrange"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.95))
                                .shadow(
                                    color: .black.opacity(0.2),
                                    radius: 3,
                                    x: 0, y: 2
                                )
                        )
                }
                Spacer()
            }
            .padding(.bottom, 5)

            Text(viewModel.levelName)
                .font(.appFont(.dylexicBold, size: 26))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
        }
    }

    private var characterGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                // Iterate over CharacterInfo objects from viewModel.availableCharacters
                // Use .id for Identifiable conformance
                ForEach(viewModel.availableCharacters, id: \.id) { characterInfo in
                    characterButton(for: characterInfo)
                }
            }
            .padding(.vertical)
        }
    }

    // characterButton now takes CharacterInfo and uses its properties
    private func characterButton(for characterInfo: CharacterInfo) -> some View {
        let status = characterInfo.status
        let isLocked = status == .locked
        
        let foregroundColor: Color
        // Adjust size for potentially longer character strings if your levels might have them
        let characterDisplaySize: CGFloat = (characterInfo.character.count > 1) ? 35 : 50

        switch status {
        case .locked:
            foregroundColor = .gray.opacity(0.4)
        case .unlocked:
            foregroundColor = Color("AppOrange")
        case .current:
            // Highlight the current character. Using red as an example.
            foregroundColor = .red
        }

        return Button {
            viewModel.characterTapped(characterInfo) // Use the correct ViewModel method
        } label: {
            Text(characterInfo.character) // Display the character string
                .font(.appFont(.dylexicBold, size: characterDisplaySize))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15),
                                radius: 4, x: 0, y: 2)
                )
                .overlay {
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray.opacity(0.5))
                            .font(.system(size: 24))
                    }
                    // Optional: Add a visual cue for the .current character
                    if status == .current {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.yellow, lineWidth: 3) // Example: yellow border
                    }
                }
        }
        .disabled(isLocked) // Disable button if character is locked
    }
}
