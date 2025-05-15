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
        repeating: .init(.flexible(), spacing: 15), count: 2
    )

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea()

                    characterGrid
                .padding(.top, geometry.safeAreaInsets.top)
                .padding(.horizontal)

                backButtonView(geometry: geometry)
            }
        }
        .onAppear {
            // It's good practice for the ViewModel to handle its onAppear logic
            viewModel.onAppear()
        }
    }

    private func backButtonView(geometry: GeometryProxy) -> some View {
        VStack {
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
                .padding(.leading)
                .padding(.top)
                Spacer()
            }
            Spacer()
        }
        .padding(.leading, geometry.safeAreaInsets.leading)
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
        .scrollIndicators(.hidden)
    }

    // characterButton now takes CharacterInfo and uses its properties
    private func characterButton(for characterInfo: CharacterInfo) -> some View {
        let status = characterInfo.status
        let isLocked = status == .locked
        
        let foregroundColor: Color


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
                .font(.appFont(.dylexicBold, size: 60))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15),
                                radius: 4, x: 0, y: 2)
                )
                .overlay {
                    if status == .current {
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(
                                Color.yellow,
                                lineWidth: 3
                            )
                    }
                }
        }
        .disabled(isLocked) // Disable button if character is locked
    }
}
