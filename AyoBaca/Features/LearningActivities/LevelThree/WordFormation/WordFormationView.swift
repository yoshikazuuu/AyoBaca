import SwiftUI
import UniformTypeIdentifiers // For drag and drop functionality

struct WordFormationView: View {
    @StateObject var viewModel: WordFormationViewModel

    // Define constants for consistent styling
    private let mainBackgroundColor = Color(red: 1, green: 0.42, blue: 0.26)
    private let tileBgColor = Color(red: 1, green: 0.88, blue: 0.56)
    private let tileTextColor = Color(hex: "#78350F")

    // Define grid layout for syllable tiles
    private let tileColumns: [GridItem] = Array(
        repeating: .init(.flexible(), spacing: 15), count: 3
    )

    var body: some View {
        ZStack {
            // Background
            mainBackgroundColor.ignoresSafeArea()

            // Mascot image (placeholder)
            VStack {
                Spacer()
                Image("words-helper")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .padding(.trailing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

            // Main content
            GeometryReader { geometry in
                VStack(spacing: 15) {
                    // Only show back button when not in welcome/tutorial screens
                    if !viewModel.isWelcomeScreen && !viewModel.isTutorialScreen {
                        backButton
                            .padding([.top, .leading])
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer(minLength: 20)

                    // Conditional content based on app state
                    if viewModel.isWelcomeScreen {
                        welcomeView
                    } else if viewModel.isTutorialScreen {
                        tutorialView
                    } else {
                        // Main activity content
                        VStack(spacing: 20) {
                            // Image display
                            imageDisplay(geometry: geometry)
                                .padding(.horizontal)

                            // Syllable drop slots container
                            syllableDropSlotsContainer
                                .padding(.horizontal)

                            // Sound button (only when word is correct)
                            if viewModel.isWordCorrect == true {
                                soundButton
                            } else {
                                // Placeholder to maintain layout consistency
                                Color.clear.frame(height: 50)
                            }

                            // Feedback text
                            feedbackDisplay
                                .padding(.horizontal)

                            // Syllable tiles grid
                            syllableTilesGrid
                                .padding(.horizontal)

                            // Next button (only when showNextButton is true)
                            if viewModel.showNextButton {
                                nextButton
                            } else {
                                // Placeholder to maintain layout consistency
                                Color.clear.frame(height: 50)
                            }
                        }
                        .padding(.bottom, 30)
                    }

                    Spacer(minLength: 0)
                }
                .frame(width: geometry.size.width)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isWordCorrect)
        .animation(.easeInOut(duration: 0.3), value: viewModel.feedbackMessage)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showNextButton)
    }

    // MARK: - Welcome Screen
    private var welcomeView: some View {
        VStack(spacing: 20) {
            // Speaker icon button
            soundButton
                .padding(.bottom, 10)

            // Welcome message
            Text("Selamat datang! Mari belajar membentuk kata-kata dari suku kata.")
                .font(.appFont(.rethinkRegular, size: 18))
                .foregroundColor(tileTextColor)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.1), radius: 3)
                )
                .padding(.horizontal)

            // Example text
            Text("contoh:")
                .font(.appFont(.rethinkRegular, size: 16))
                .foregroundColor(.white)
                .padding(.top, 10)

            // Example image ("mata" - eye)
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 3)

                Image(systemName: "eye.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(mainBackgroundColor)
                    .padding(30)
            }
            .frame(height: 150)
            .padding(.horizontal)

            // Example syllables "MA" and "TA"
            HStack(spacing: 15) {
                Text("MA")
                    .font(.appFont(.dylexicBold, size: 24))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 60)
                    .background(Color(hex: "#94BE3E"))
                    .cornerRadius(10)

                Text("TA")
                    .font(.appFont(.dylexicBold, size: 24))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 60)
                    .background(Color(hex: "#94BE3E"))
                    .cornerRadius(10)
            }
            .padding(.vertical, 20)

            // Start button
            Button {
                viewModel.startActivity()
            } label: {
                Text("Mulai")
                    .font(.appFont(.rethinkBold, size: 18))
                    .foregroundColor(tileTextColor)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 40)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 3)
                    )
            }
            .padding(.top, 20)
        }
        .padding()
    }

    // MARK: - Tutorial View
    private var tutorialView: some View {
        VStack(spacing: 20) {
            // Speaker icon button
            soundButton
                .padding(.bottom, 10)

            // Tutorial instruction
            Text("Kamu akan menyusun suku kata untuk membuat kata yang lengkap.")
                .font(.appFont(.rethinkRegular, size: 18))
                .foregroundColor(tileTextColor)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.1), radius: 3)
                )
                .padding(.horizontal)

            // Example text
            Text("contoh:")
                .font(.appFont(.rethinkRegular, size: 16))
                .foregroundColor(.white)
                .padding(.top, 10)

            // Example image ("mata" - eye)
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 3)

                Image(systemName: "eye.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(mainBackgroundColor)
                    .padding(30)
            }
            .frame(height: 150)
            .padding(.horizontal)

            // Example syllables "MA" and "TA"
            HStack(spacing: 15) {
                Text("MA")
                    .font(.appFont(.dylexicBold, size: 24))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 60)
                    .background(Color(hex: "#94BE3E"))
                    .cornerRadius(10)

                Text("TA")
                    .font(.appFont(.dylexicBold, size: 24))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 60)
                    .background(Color(hex: "#94BE3E"))
                    .cornerRadius(10)
            }
            .padding(.vertical, 20)


            // Continue button
            Button {
                viewModel.completeTutorial()
            } label: {
                Text("Selanjutnya")
                    .font(.appFont(.rethinkBold, size: 18))
                    .foregroundColor(tileTextColor)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 3)
                    )
            }
            .padding(.top, 10)
        }
        .padding()
    }

    // MARK: - Main Game Components

    private var backButton: some View {
        Button {
            viewModel.navigateBack()
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
                            radius: 3, x: 0, y: 2
                        )
                )
        }
    }

    private var instructionText: some View {
        Text(viewModel.instructionText)
            .font(.appFont(.rethinkRegular, size: 18))
            .foregroundColor(tileTextColor)
            // Removed .lineLimit(2) to allow text to wrap to multiple lines
            .multilineTextAlignment(.center)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 3)
            )
            .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
    }

    private func imageDisplay(geometry: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 3)

            if let imageName = viewModel.currentTask?.imageName {
                if imageName == "icon_mata" {
                    Image(systemName: "eye.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(mainBackgroundColor)
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
                        .foregroundColor(mainBackgroundColor)
                }
            } else {
                ProgressView()
            }
        }
        .frame(height: geometry.size.height * 0.22)
    }

    private var syllableDropSlotsContainer: some View {
        HStack(spacing: 15) {
            ForEach(0..<(viewModel.currentTask?.correctSyllables.count ?? 2), id: \.self) { index in
                syllableSlotView(index: index)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 3)
        )
    }

    private func syllableSlotView(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    viewModel.isWordCorrect == false ? Color.red.opacity(0.7) : mainBackgroundColor.opacity(0.5),
                    style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                )
                .frame(width: 80, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.6))
                )

            if let tile = viewModel.syllableSlots[safe: index], let actualTile = tile {
                Text(actualTile.text)
                    .font(.appFont(.dylexicBold, size: 24))
                    .foregroundColor(tileTextColor)
            }
        }
        .frame(width: 80, height: 60)
        .onTapGesture {
            viewModel.slotTapped(index)
        }
        .onDrop(
            of: [UTType.text],
            delegate: SyllableDropDelegate(
                viewModel: viewModel,
                slotIndex: index
            )
        )
        .overlay {
            if viewModel.isWordCorrect == true {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#94BE3E"), lineWidth: 3)
            }
        }
    }

    private var soundButton: some View {
        Button {
            viewModel.playCurrentWordSound()
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 50))
                .foregroundStyle(.white)
        }
        .frame(height: 50)
    }

    private var feedbackDisplay: some View {
        Text(viewModel.feedbackMessage)
            .font(.appFont(.rethinkRegular, size: 16))
            .foregroundColor(viewModel.isWordCorrect == true ? .green : .yellow)
            .padding(viewModel.feedbackMessage.isEmpty ? 0 : 8)
            .background(
                viewModel.feedbackMessage.isEmpty ? Color.clear : Color.white.opacity(0.9)
            )
            .cornerRadius(10)
            .frame(minHeight: 30)
    }

    private var syllableTilesGrid: some View {
        LazyVGrid(columns: tileColumns, spacing: 15) {
            ForEach(viewModel.availableSyllableTiles) { tile in
                Text(tile.text)
                    .font(.appFont(.dylexicBold, size: 22))
                    .foregroundColor(tileTextColor)
                    .frame(width: 60, height: 60)
                    .background(tileBgColor)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.1), radius: 2)
                    .onTapGesture {
                        viewModel.tileTapped(tile)
                    }
                    .draggable(tile.text)
            }
        }
    }

    private var nextButton: some View {
        Button {
            viewModel.nextWordTask()
        } label: {
            Text("Selanjutnya")
                .font(.appFont(.rethinkBold, size: 18))
                .foregroundColor(tileTextColor)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 3)
                )
        }
        .frame(height: 50)
    }
}

// Drop Delegate for handling syllable drops
struct SyllableDropDelegate: DropDelegate {
    let viewModel: WordFormationViewModel
    let slotIndex: Int

    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [UTType.text]).first else {
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
