//
//  SyllableView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 16/05/25.
//


import SwiftUI

struct SyllableView: View {
    @StateObject var viewModel: SyllableViewModel
    
    var body: some View {
        ZStack {
            // Green background from screenshots
            Color(red: 0.7, green: 0.9, blue: 0.4).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Back button
                HStack {
                    Button {
                        viewModel.navigateBack()
                    } label: {
                        Text("Kembali")
                            .font(.appFont(.rethinkRegular, size: 16))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.white))
                    }
                    .padding(.leading)
                    Spacer()
                }
                
                // Instructions
                Text(viewModel.currentTaskType.instructions)
                    .font(.appFont(.rethinkRegular, size: 18))
                    .foregroundColor(.brown)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 3)
                    )
                    .padding(.horizontal)
                
                // Slots container
                HStack(spacing: 15) {
                    ForEach(0..<viewModel.slotCount, id: \.self) { index in
                        letterSlot(at: index)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 3)
                )
                .padding(.horizontal)
                
                // Speaker button if combination is correct
                if viewModel.isCorrectCombination == true {
                    Button {
                        viewModel.playSound()
                    } label: {
                        Image(systemName: "speaker.wave.2")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(15)
                            .background(Circle().fill(Color.gray.opacity(0.6)))
                    }
                    .padding(.top, 5)
                }
                
                // Feedback message
                if !viewModel.feedbackMessage.isEmpty {
                    Text(viewModel.feedbackMessage)
                        .font(.appFont(.rethinkRegular, size: 16))
                        .foregroundColor(viewModel.isCorrectCombination == true ? .green : .red)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                        .padding(.horizontal)
                }
                
                // Available letter tiles in a grid
                VStack(spacing: 15) {
                    let columns = viewModel.availableLetters.count > 3 ? 3 : viewModel.availableLetters.count
                    let rows = (viewModel.availableLetters.count + columns - 1) / columns
                    
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 15) {
                            ForEach(0..<columns, id: \.self) { col in
                                let index = row * columns + col
                                if index < viewModel.availableLetters.count {
                                    letterTile(for: viewModel.availableLetters[index])
                                } else {
                                    Color.clear.frame(width: 60, height: 60) // Placeholder
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
                
                // Next button when combination is correct
                if viewModel.showNextButton {
                    Button {
                        viewModel.nextTask()
                    } label: {
                        Text("Selanjutnya")
                            .font(.appFont(.rethinkRegular, size: 18))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.7))
                                    .shadow(color: .black.opacity(0.2), radius: 2)
                            )
                    }
                }
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }
    
    private func letterSlot(at index: Int) -> some View {
        ZStack {
            // Empty slot with dashed border
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    viewModel.isCorrectCombination == false ? Color.red : Color.yellow,
                    style: StrokeStyle(lineWidth: 2, dash: viewModel.isCorrectCombination == true ? [] : [5, 5])
                )
                .frame(width: 70, height: 70)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.2))
                )
            
            // Letter in slot if present
            if let tile = viewModel.slotLetters[index] {
                Text(tile.letter)
                    .font(.appFont(.dylexicBold, size: 36))
                    .foregroundColor(tile.type == .consonant ? Color("AppOrange") : .blue)
            }
        }
        .overlay(
            viewModel.isCorrectCombination == true ?
                RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green, lineWidth: 3)
                : nil
        )
        .onDrop(of: [.text], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            provider.loadObject(ofClass: NSString.self) { item, _ in
                if let letter = item as? String {
                    DispatchQueue.main.async {
                        viewModel.handleDrop(letter: letter, at: index)
                    }
                }
            }
            return true
        }
    }
    
    private func letterTile(for tile: SyllableViewModel.LetterTile) -> some View {
        Text(tile.letter)
            .font(.appFont(.dylexicBold, size: 36))
            .foregroundColor(tile.type == .consonant ? Color("AppOrange") : .blue)
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 2)
            )
            .onDrag {
                NSItemProvider(object: tile.letter as NSString)
            }
    }
}
