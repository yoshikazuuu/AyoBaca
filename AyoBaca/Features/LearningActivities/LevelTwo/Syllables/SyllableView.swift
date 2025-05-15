// ./Features/LearningActivities/LevelTwo/Syllables/SyllableView.swift
// View for the Syllable construction activity (Level 2)

import SwiftUI
import UniformTypeIdentifiers // For onDrop

struct SyllableView: View {
    @StateObject var viewModel: SyllableViewModel
    
    var body: some View {
        ZStack {
            // Green background from screenshots
            Color(red: 0.7, green: 0.9, blue: 0.4).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Back button - Updated Style
                HStack {
                    Button {
                        viewModel.navigateBack()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.title2.weight(.semibold))
                            .padding(12)
                            .background(Color.white.opacity(0.8)) // Adjusted opacity
                            .foregroundColor(Color("AppOrange")) // Consistent color
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 3)
                    }
                    .padding([.leading, .top]) // Added top padding for better spacing
                    Spacer()
                }
                
                // Instructions
                Text(viewModel.currentTaskType.instructions)
                    .font(.appFont(.rethinkRegular, size: 18))
                    .foregroundColor(.brown) // Keep original color
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
                        Image(systemName: "speaker.wave.2.fill") // Filled icon
                            .font(.system(size: 24))
                            .foregroundColor(Color("AppOrange")) // Consistent color
                            .padding(15)
                            .background(Circle().fill(Color.white).shadow(radius: 2)) // White background
                    }
                    .padding(.top, 5)
                } else {
                    // Placeholder to maintain layout consistency when button is not shown
                     Color.clear.frame(height: 50 + 5) // Approx height of button + padding
                }
                
                // Feedback message
                if !viewModel.feedbackMessage.isEmpty {
                    Text(viewModel.feedbackMessage)
                        .font(.appFont(.rethinkRegular, size: 16))
                        .foregroundColor(viewModel.isCorrectCombination == true ? Color.green.opacity(0.9) : Color.red.opacity(0.8))
                        .padding(viewModel.feedbackMessage.isEmpty ? 0 : 10)
                        .background(
                             viewModel.feedbackMessage.isEmpty ? Color.clear : Color.white.opacity(0.9)
                        )
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.05), radius: 2)
                        .frame(minHeight: 30)
                        .animation(.easeInOut, value: viewModel.feedbackMessage)
                        .padding(.horizontal)
                } else {
                    // Placeholder to maintain layout consistency
                    Color.clear.frame(height: 30 + 20) // Approx height of feedback + padding
                }
                
                // Available letter tiles in a grid
                VStack(spacing: 15) {
                    let columns = viewModel.availableLetters.count > 4 ? 4 : (viewModel.availableLetters.isEmpty ? 1 : viewModel.availableLetters.count)
                    let rows = viewModel.availableLetters.isEmpty ? 0 : (viewModel.availableLetters.count + columns - 1) / columns
                    
                    if viewModel.availableLetters.isEmpty && viewModel.isCorrectCombination != true {
                        Text("Tidak ada huruf tersisa.")
                            .font(.appFont(.rethinkRegular, size: 16))
                            .foregroundColor(.gray)
                            .padding()
                    } else {
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
                }
                .padding(.vertical)
                
                // Next button when combination is correct
                if viewModel.showNextButton {
                    Button {
                        viewModel.nextTask()
                    } label: {
                        Text("Selanjutnya")
                            .font(.appFont(.rethinkBold, size: 18)) // Bolder font
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(
                                Capsule()
                                    .fill(Color.orange.opacity(0.8)) // Brighter color
                                    .shadow(color: .black.opacity(0.2), radius: 3, x:0, y:2)
                            )
                    }
                } else {
                     // Placeholder to maintain layout consistency
                     Color.clear.frame(height: 50 + 15) // Approx height of button + padding
                }
                
                Spacer(minLength: 0) // Pushes content up
            }
            // .padding(.top, 40) // Removed to allow back button to be at very top with its own padding
        }
    }
    
    private func letterSlot(at index: Int) -> some View {
        ZStack {
            // Empty slot with dashed border
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    viewModel.isCorrectCombination == false ? Color.red.opacity(0.7) : Color.yellow.opacity(0.8), // Adjusted colors
                    style: StrokeStyle(lineWidth: 2, dash: viewModel.isCorrectCombination == true ? [] : [6, 4]) // Adjusted dash
                )
                .frame(width: 70, height: 70)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.5)) // Slightly more opaque
                )
            
            // Letter in slot if present
            if let tile = viewModel.slotLetters[index] {
                Text(tile.letter)
                    .font(.appFont(.dylexicBold, size: 36))
                    .foregroundColor(tile.type == .consonant ? Color("AppOrange") : .blue.opacity(0.9))
            }
        }
        .overlay(
            viewModel.isCorrectCombination == true ?
                RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green.opacity(0.9), lineWidth: 3) // Adjusted color
                : nil
        )
        .onDrop(of: [UTType.text], isTargeted: nil) { providers in // Use UTType.text
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
            .foregroundColor(tile.type == .consonant ? Color("AppOrange") : .blue.opacity(0.9))
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
