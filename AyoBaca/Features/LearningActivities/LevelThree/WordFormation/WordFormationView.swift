// ./Features/LearningActivities/LevelThree/WordFormation/WordFormationView.swift
// View for the Word Formation Activity (Level 3)

import SwiftUI
import UniformTypeIdentifiers // Added import for UTType

struct WordFormationView: View {
    @StateObject var viewModel: WordFormationViewModel

    // Define grid layout for syllable tiles
    private let tileColumns: [GridItem] = Array(
        repeating: .init(.flexible(), spacing: 15), count: 3
    )

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea() // Background from image

                VStack(spacing: 15) {
                    header(geometry: geometry)
                    instructionText
                    imageDisplay(geometry: geometry)
                    syllableDropSlotsContainer(geometry: geometry) // Changed to use container

                    if viewModel.isWordCorrect == true {
                        soundButton
                    } else {
                        // Placeholder to maintain layout consistency
                        Color.clear.frame(height: 50)
                    }
                    
                    feedbackDisplay

                    syllableTilesGrid(geometry: geometry)

                    if viewModel.showNextButton {
                        nextButton
                    } else {
                        // Placeholder to maintain layout consistency
                        Color.clear.frame(height: 50)
                    }
                    Spacer(minLength: 0) // Pushes content up
                }
                .padding()
            }
        }
    }

    // MARK: - Subviews
    private func header(geometry: GeometryProxy) -> some View {
        HStack {
            Button {
                viewModel.navigateBack()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.title2.weight(.semibold))
                    .padding(12)
                    .background(Color.white.opacity(0.7))
                    .foregroundColor(Color("AppOrange"))
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
            Spacer()
        }
        .padding(.bottom, 5)
    }

    private var instructionText: some View {
        Text(viewModel.instructionText)
            .font(.appFont(.rethinkRegular, size: 18))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .frame(minHeight: 50)
    }

    private func imageDisplay(geometry: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            if let imageName = viewModel.currentTask?.imageName {
                if imageName == "icon_mata" {
                    Image(systemName: "eye.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color("AppOrange"))
                        .padding(30)
                } else if imageName == "icon_buku" {
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.blue)
                        .padding(30)
                } else if imageName == "icon_meja" {
                    Image(systemName: "table.furniture.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.brown)
                        .padding(30)
                } else {
                    Text(viewModel.currentTask?.targetWord ?? "")
                       .font(.appFont(.dylexicBold, size: 40))
                       .foregroundColor(Color("AppOrange"))
                }
            } else {
                ProgressView()
            }
        }
        .frame(height: geometry.size.height * 0.22)
    }

    // Container for syllable drop slots to use the helper function
    private func syllableDropSlotsContainer(geometry: GeometryProxy) -> some View {
        HStack(spacing: 10) {
            ForEach(0..<(viewModel.currentTask?.correctSyllables.count ?? 2), id: \.self) { index in
                syllableSlotView(index: index, geometry: geometry) // Use the helper
            }
        }
        .padding(.vertical, 5)
    }

    // Helper function for a single slot view to simplify the main body
    @ViewBuilder
    private func syllableSlotView(index: Int, geometry: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.9))
                .frame(width: 80, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            viewModel.isWordCorrect == false ? Color.red.opacity(0.7) : Color("AppOrange").opacity(0.5),
                            style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                        )
                )

            if let tile = viewModel.syllableSlots[safe: index], let actualTile = tile {
                Text(actualTile.text)
                    .font(.appFont(.dylexicBold, size: 24))
                    .foregroundColor(Color("AppOrange"))
            }
        }
        .frame(width: 80, height: 60)
        .onTapGesture {
            viewModel.slotTapped(index)
        }
        .onDrop(
            of: [UTType.text], // UTType.text is now recognized
            delegate: SyllableDropDelegate(
                viewModel: viewModel,
                slotIndex: index
            )
        )
        .overlay {
            if viewModel.isWordCorrect == true {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.green, lineWidth: 3)
            }
        }
    }
    
    private var soundButton: some View {
        Button {
            viewModel.playCurrentWordSound()
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 24))
                .foregroundColor(Color("AppOrange"))
                .padding(12)
                .background(Circle().fill(Color.white).shadow(radius: 2))
        }
        .frame(height: 50)
    }
    
    private var feedbackDisplay: some View {
        Text(viewModel.feedbackMessage)
            .font(.appFont(.rethinkRegular, size: 16))
            .foregroundColor(viewModel.isWordCorrect == true ? .green.opacity(0.8) : .yellow.opacity(0.9))
            .padding(viewModel.feedbackMessage.isEmpty ? 0 : 8)
            .background(
                viewModel.feedbackMessage.isEmpty ? Color.clear : Color.black.opacity(0.2)
            )
            .cornerRadius(10)
            .frame(minHeight: 30)
            .animation(.easeInOut, value: viewModel.feedbackMessage)
    }

    private func syllableTilesGrid(geometry: GeometryProxy) -> some View {
        ScrollView {
            LazyVGrid(columns: tileColumns, spacing: 15) {
                ForEach(viewModel.availableSyllableTiles) { tile in
                    Text(tile.text)
                        .font(.appFont(.dylexicBold, size: 22))
                        .foregroundColor(Color("AppOrange"))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("AppYellow"))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .onTapGesture {
                             viewModel.tileTapped(tile)
                        }
                        .draggable(tile.text)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: geometry.size.height * 0.25)
    }

    private var nextButton: some View {
        Button {
            viewModel.nextWordTask()
        } label: {
            Text("Selanjutnya")
                .font(.appFont(.rethinkBold, size: 18))
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .background(Color.gray.opacity(0.7))
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
        }
        .frame(height: 50)
        .padding(.top, 5)
    }
}

// Drop Delegate for handling syllable drops
struct SyllableDropDelegate: DropDelegate {
    let viewModel: WordFormationViewModel
    let slotIndex: Int

    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [UTType.text]).first else { // UTType.text is now recognized
            return false
        }

        itemProvider.loadObject(ofClass: NSString.self) { (object, error) in
            if let text = object as? String {
                if let droppedTile = viewModel.availableSyllableTiles.first(where: { $0.text == text }) {
                    DispatchQueue.main.async {
                        viewModel.handleDrop(syllableTile: droppedTile, atSlotIndex: slotIndex)
                    }
                } else if let alreadySlottedTile = viewModel.syllableSlots.compactMap({$0}).first(where: {$0.text == text}) {
                     DispatchQueue.main.async {
                        viewModel.handleDrop(syllableTile: alreadySlottedTile, atSlotIndex: slotIndex)
                    }
                }
            }
        }
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

// Helper to safely access array elements
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Preview
#if DEBUG
struct WordFormationView_Previews: PreviewProvider {
    static var previews: some View {
        let appStateManager = AppStateManager()
        let levelDef = LevelDefinition(
            id: 3,
            position: .zero,
            range: "WORD"..."WORD",
            name: "Gunung Kata"
        )
        WordFormationView(
            viewModel: WordFormationViewModel(
                appStateManager: appStateManager,
                levelDefinition: levelDef
            )
        )
    }
}
#endif
