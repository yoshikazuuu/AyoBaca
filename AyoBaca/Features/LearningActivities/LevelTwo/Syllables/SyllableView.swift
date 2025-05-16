// ./Features/LearningActivities/LevelTwo/Syllables/SyllableView.swift

import SwiftUI
import UniformTypeIdentifiers // For onDrop

struct SyllableView: View {
    @StateObject var viewModel: SyllableViewModel

    // Define colors for tiles consistent with tutorial examples
    private let tutorialConsonantColor = Color(hex: "#60A5FA") // Blueish for 'B'
    private let tutorialVowelColor = Color(hex: "#FACC15")     // Yellowish for 'A' (source)
    private let tutorialAvailableTileColor = Color(hex: "#F3EAD3") // Creamy for bottom tiles
    private let tutorialAvailableTileTextColor = Color(hex: "#78350F") // Brownish text
    private let mainBackgroundColor = Color(hex: "#A3E635") // Light Green background

    var body: some View {
        ZStack {
            mainBackgroundColor.ignoresSafeArea()

            if viewModel.showTutorial {
                tutorialView(for: viewModel.tutorialContents[viewModel.currentTutorialPage])
            } else {
                mainActivityView
            }
        }
        // Apply animations at a higher level for smoother transitions
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showTutorial)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentTutorialPage)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isTutorialStepCorrect)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isCorrectCombination)
        .animation(.easeInOut(duration: 0.3), value: viewModel.tutorialFeedbackMessage)
        .animation(.easeInOut(duration: 0.3), value: viewModel.feedbackMessage)
        .animation(.easeInOut(duration: 0.3), value: viewModel.slotLetters) // Add animation for slot letter changes
    }

    // MARK: - Main Activity View
    @ViewBuilder
    private var mainActivityView: some View {
        VStack(spacing: 15) {
            mainBackButton.padding([.leading, .top])
            
            Text(viewModel.currentTaskType.instructions)
                .font(.appFont(.rethinkRegular, size: 18))
                .foregroundColor(tutorialAvailableTileTextColor) // Consistent text color
                .multilineTextAlignment(.center)
                .padding()
                .background(contentBoxBackground())
                .padding(.horizontal)

            HStack(spacing: 15) {
                ForEach(0..<viewModel.slotCount, id: \.self) { index in
                    letterSlotView(
                        tile: viewModel.slotLetters[safe: index] ?? nil,
                        isTutorial: false,
                        slotIndex: index,
                        isCorrect: viewModel.isCorrectCombination
                    )
                }
            }
            .padding()
            .background(contentBoxBackground(height: 100)) // Fixed height for consistency
            .padding(.horizontal)

            if viewModel.isCorrectCombination == true {
                soundButton(action: viewModel.playSound)
            } else {
                Color.clear.frame(height: 50) // Placeholder for sound button
            }

            if !viewModel.feedbackMessage.isEmpty {
                feedbackMessageView(
                    text: viewModel.feedbackMessage,
                    isCorrect: viewModel.isCorrectCombination == true
                )
            } else {
                Color.clear.frame(height: 40) // Placeholder for feedback
            }

            availableLetterTilesGrid_MainGame.padding(.vertical, 10)

            if viewModel.showNextButton {
                nextButton(title: "Selanjutnya", action: viewModel.nextTask)
            } else {
                Color.clear.frame(height: 50) // Placeholder for next button
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - Tutorial View
    @ViewBuilder
    private func tutorialView(for content: SyllableViewModel.TutorialPageContent) -> some View {
        GeometryReader { geometry in
            VStack(spacing: 10) { // Reduced spacing for tutorial layout
                mainBackButton.padding([.leading, .top])
                Spacer(minLength: 10)

                if content.showMainSpeakerButton {
                    soundButton { viewModel.playTutorialSound(pageIndex: content.id) }
                        .scaleEffect(1.2) // Make tutorial speaker slightly larger
                }

                Text(content.instructionText)
                    .font(.appFont(.rethinkRegular, size: 18))
                    .foregroundColor(tutorialAvailableTileTextColor)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(contentBoxBackground())
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true) // Allow text to wrap

                // --- Interactive/Display Tutorial Content Area ---
                Group {
                    if content.id == 1 { // Page 2: "Sila adalah..." - Static B and A example
                        tutorialPage2DisplayContent(content: content)
                    } else if content.id == 2 { // Page 3: "Susun huruf..." - User drags 'B'
                        tutorialPage3DragBContent(content: content)
                    } else if content.id == 3 { // Page 4: "Sekarang, geser A..." - 'B' pre-filled, user drags 'A'
                        tutorialPage4DragAContent(content: content)
                    } else { // Default for page 1 or any other non-interactive page
                         Color.clear.frame(minHeight: 120) // Placeholder
                    }
                }
                .padding(.vertical, 5)
                .frame(minHeight: 120) // Ensure consistent height for content area

                if !viewModel.tutorialFeedbackMessage.isEmpty {
                    feedbackMessageView(
                        text: viewModel.tutorialFeedbackMessage,
                        isCorrect: viewModel.isTutorialStepCorrect == true
                    )
                } else {
                     Color.clear.frame(height: 30) // Placeholder for feedback
                }

                Spacer(minLength: 10)

                // Show bottom tiles only on page 4 (index 3) for dragging 'A'
                if content.showBottomTilesInteractionArea && content.id == 3 {
                    tutorialBottomLetterTiles_ForPage4().padding(.bottom, 5)
                } else {
                    Color.clear.frame(height: 100) // Placeholder if no bottom tiles
                }
                
                // Mascot Placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.2)) // Simple placeholder
                    .frame(height: geometry.size.height * 0.2)
                    .overlay(Text(content.mascotPlaceholderText).foregroundColor(.white.opacity(0.5)))
                    .cornerRadius(15)
                    .padding(.horizontal)

                nextButton(title: content.bottomButtonText) {
                    if content.id == viewModel.tutorialPagesCount - 1 { // Last tutorial page
                        viewModel.startActivity()
                    } else {
                        viewModel.nextTutorialPage()
                    }
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom + 10) // Ensure button is above safe area
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                // Setup interactions specific to this tutorial page when it appears
                viewModel.setupTutorialPageInteractions(pageId: content.id)
            }
        }
    }

    // MARK: - Tutorial Sub-components (Interactive & Display)

    @ViewBuilder
    private func tutorialPage2DisplayContent(content: SyllableViewModel.TutorialPageContent) -> some View {
        // Page 2 (index 1 in tutorialContents): "Sila adalah..." - Shows static B and A example.
        VStack(spacing: 10) {
            Text(content.examplePrimaryText ?? "contoh:")
                .font(.appFont(.dylexicBold, size: 18))
                .foregroundColor(tutorialAvailableTileTextColor)
            HStack(spacing: 10) {
                // Static 'B' tile for display
                if let bTile = viewModel.tutorialDraggable_B_ForPage3 { // Re-use the B tile definition
                    letterTileView(tile: bTile, backgroundColor: tutorialConsonantColor, textColor: .white, isDraggable: false, isTutorial: true)
                }
                // Static 'A' tile for display
                if let aTile = viewModel.tutorialStatic_A_ForPage2 {
                    letterTileView(tile: aTile, backgroundColor: tutorialVowelColor, textColor: .white, isDraggable: false, isTutorial: true)
                }
            }
            if let hint = content.exampleSoundAccessibilityHint {
                tutorialSoundHint(hintText: hint) { viewModel.playTutorialSound(pageIndex: content.id) }
            }
        }
        .padding()
        .background(contentBoxBackground(height: 180)) // Give it enough height
        .padding(.horizontal)
    }

    @ViewBuilder
    private func tutorialPage3DragBContent(content: SyllableViewModel.TutorialPageContent) -> some View {
        // Page 3 (index 2 in tutorialContents): "Susun huruf..." - User drags 'B' into the first slot.
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                // Draggable "B" area OR "B" in slot
                if let bTile = viewModel.tutorialDraggable_B_ForPage3 { // If B is still available to drag
                    letterTileView(tile: bTile, backgroundColor: tutorialConsonantColor, textColor: .white, isDraggable: true, isTutorial: true)
                } else { // B has been dragged into the slot
                    letterSlotView(
                        tile: viewModel.tutorialSlotLetters[safe: 0] ?? nil,
                        isTutorial: true,
                        slotIndex: 0,
                        isCorrect: viewModel.isTutorialStepCorrect
                    )
                }
                // Empty second slot (visual only for this page, not a drop target yet)
                letterSlotView(tile: nil, isTutorial: true, slotIndex: 1, isCorrect: nil) // isCorrect is nil as it's not part of this step's validation
            }
            if let hint = content.exampleSoundAccessibilityHint {
                 tutorialSoundHint(hintText: hint, isSpeakerDisabled: true) {} // Speaker disabled until BA formed on next page
            }
        }
        .padding()
        .background(contentBoxBackground(height: 150))
        .padding(.horizontal)
    }

    @ViewBuilder
    private func tutorialPage4DragAContent(content: SyllableViewModel.TutorialPageContent) -> some View {
        // Page 4 (index 3 in tutorialContents): "Sekarang, geser A..." - 'B' is pre-filled, user drags 'A'.
        VStack(spacing: 10) {
            if let primaryText = content.examplePrimaryText { // "Selamat mencoba!"
                Text(primaryText)
                    .font(.appFont(.dylexicBold, size: 18))
                    .foregroundColor(tutorialAvailableTileTextColor)
            }
            HStack(spacing: 10) {
                // Slot 0 shows 'B' (pre-filled by ViewModel logic for this page)
                letterSlotView(
                    tile: viewModel.tutorialSlotLetters[safe: 0] ?? nil,
                    isTutorial: true,
                    slotIndex: 0,
                    isCorrect: viewModel.isTutorialStepCorrect
                )
                // Slot 1 is the drop target for 'A'
                letterSlotView(
                    tile: viewModel.tutorialSlotLetters[safe: 1] ?? nil,
                    isTutorial: true,
                    slotIndex: 1,
                    isCorrect: viewModel.isTutorialStepCorrect
                )
            }
            if viewModel.showTutorialSyllableSpeaker { // If "BA" is correctly formed
                soundButton(action: viewModel.playTutorialConstructedSyllableSound)
            } else if let hint = content.exampleSoundAccessibilityHint { // General hint for this page
                 tutorialSoundHint(hintText: "Geser 'A' untuk melengkapi 'BA'.", isSpeakerDisabled: true) {}
            }
        }
        .padding()
        .background(contentBoxBackground(height: 150))
        .padding(.horizontal)
    }

    @ViewBuilder
    private func tutorialBottomLetterTiles_ForPage4() -> some View {
        // These are for tutorial page 4 (index 3), where 'A' is draggable.
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), // 3 columns
            spacing: 10
        ) {
            ForEach(viewModel.tutorialAvailableLetters_Page4) { tile in
                letterTileView(
                    tile: tile,
                    backgroundColor: tutorialAvailableTileColor, // Creamy background
                    textColor: tutorialAvailableTileTextColor,   // Brownish text
                    isDraggable: tile.letter == "A", // Only 'A' is draggable on this page
                    isTutorial: true
                )
            }
        }
        .padding(.horizontal, 40) // Adjust padding for centering
        .frame(maxHeight: 140) // Enough for 2 rows of 3 tiles
    }
    
    @ViewBuilder
    private func tutorialSoundHint(hintText: String, isSpeakerDisabled: Bool = false, action: @escaping () -> Void = {}) -> some View {
        HStack(spacing: 8) {
            Button(action: action) {
                Image(systemName: isSpeakerDisabled ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isSpeakerDisabled ? .gray.opacity(0.6) : .white)
                    .padding(8)
                    .background(Circle().fill(isSpeakerDisabled ? Color.white.opacity(0.5) : Color("AppOrange").opacity(0.8)))
            }.disabled(isSpeakerDisabled)
            Text(hintText)
                .font(.appFont(.rethinkRegular, size: 12))
                .foregroundColor(tutorialAvailableTileTextColor.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                .lineLimit(2)
        }
        .padding(.horizontal, 5) // Minimal horizontal padding for the hint itself
    }

    // MARK: - Shared UI Components
    @ViewBuilder
    private var mainBackButton: some View {
        HStack {
            Button { viewModel.navigateBack() } label: {
                Text("Kembali")
                    .font(.appFont(.rethinkBold, size: 16))
                    .foregroundColor(Color("AppOrange"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.white.opacity(0.9)).shadow(color: .black.opacity(0.1), radius: 2))
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func soundButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 24))
                .foregroundColor(Color("AppOrange")) // Orange speaker icon
                .padding(12)
                .background(Circle().fill(Color.white).shadow(color: .black.opacity(0.1), radius: 2))
        }
        .frame(height: 50) // Consistent height
    }

    @ViewBuilder
    private func feedbackMessageView(text: String, isCorrect: Bool) -> some View {
        Text(text)
            .font(.appFont(.rethinkRegular, size: 14))
            .foregroundColor(isCorrect ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
            .padding(8)
            .background(Color.white.opacity(0.8).cornerRadius(10))
            .shadow(color: .black.opacity(0.05), radius: 1)
            .frame(minHeight: 30) // Ensure it has some height even if text is short
            .padding(.horizontal)
    }
    
    @ViewBuilder
    private func nextButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.appFont(.rethinkBold, size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color("AppOrange")).shadow(color: .black.opacity(0.15), radius: 2, y: 1))
        }
        .frame(height: 50) // Consistent height
    }

    @ViewBuilder
    private func contentBoxBackground(height: CGFloat? = nil) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color("AppOrange").opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [6,4]))
            )
            .frame(height: height) // Optional fixed height
    }

    // Generic Letter Tile View (Used by tutorial and main game)
    @ViewBuilder
    private func letterTileView(tile: SyllableViewModel.LetterTile, backgroundColor: Color, textColor: Color, isDraggable: Bool, isTutorial: Bool) -> some View {
        Text(tile.letter)
            .font(.appFont(.dylexicBold, size: 36))
            .foregroundColor(textColor)
            .frame(width: 60, height: 60)
            .background(RoundedRectangle(cornerRadius: 10).fill(backgroundColor).shadow(color: .black.opacity(0.1), radius: 1))
            .overlay( // Dashed border for tutorial bottom available tiles
                 RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        (isTutorial && backgroundColor == tutorialAvailableTileColor) ? Color("AppOrange").opacity(0.5) : Color.clear, // Only for specific tutorial tiles
                        style: StrokeStyle(lineWidth: 2, dash: [4,3])
                    )
            )
            .onDrag {
                if isDraggable {
                    return NSItemProvider(object: tile.letter as NSString)
                }
                return NSItemProvider() // Non-draggable
            }
    }
    
    // Generic Letter Slot View (Used by tutorial and main game)
    @ViewBuilder
    private func letterSlotView(tile: SyllableViewModel.LetterTile?, isTutorial: Bool, slotIndex: Int, isCorrect: Bool?) -> some View {
        ZStack {
            let baseBorderColor = isCorrect == false ? Color.red.opacity(0.6) : Color.yellow.opacity(0.7)
            
            RoundedRectangle(cornerRadius: 15)
                .stroke(baseBorderColor, style: StrokeStyle(lineWidth: 2, dash: isCorrect == true ? [] : [6,4]))
                .frame(width: 70, height: 70)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.6)))

            if let currentTile = tile {
                // Display the letter in appropriate color based on letter type
                Text(currentTile.letter)
                    .font(.appFont(.dylexicBold, size: 36))
                    .foregroundColor(isTutorial ?
                        slotTextColor(for: currentTile, isTutorial: isTutorial) :
                        (currentTile.type == .consonant ? .white : .white))
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isTutorial ?
                                  (currentTile.letter == "B" ? tutorialConsonantColor :
                                   (currentTile.letter == "A" ? tutorialVowelColor : Color.clear)) :
                                  (currentTile.type == .consonant ? tutorialConsonantColor : tutorialVowelColor))
                    )
            }
        }
        .overlay(
            isCorrect == true ? RoundedRectangle(cornerRadius: 15).stroke(Color.green.opacity(0.9), lineWidth: 3) : nil
        )
        .onDrop(of: [UTType.text], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            provider.loadObject(ofClass: NSString.self) { item, _ in
                if let letterString = item as? String {
                    DispatchQueue.main.async {
                        var tileToDrop: SyllableViewModel.LetterTile?
                        if isTutorial {
                            if viewModel.currentTutorialPage == 2 && letterString == "B" {
                                tileToDrop = viewModel.tutorialDraggable_B_ForPage3
                            } else if viewModel.currentTutorialPage == 3 && letterString == "A" {
                                tileToDrop = viewModel.tutorialAvailableLetters_Page4.first { $0.letter == "A" }
                            }
                            if let tile = tileToDrop {
                                viewModel.handleTutorialDrop(droppedTile: tile, slotIndex: slotIndex)
                            }
                        } else {
                            viewModel.handleDrop(letter: letterString, at: slotIndex)
                        }
                    }
                }
            }
            return true
        }
    }

    // Main game's available letter tiles grid
    @ViewBuilder
    private var availableLetterTilesGrid_MainGame: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: viewModel.availableLetters.count > 4 ? 4 : max(1, viewModel.availableLetters.count)),
            spacing: 10
        ) {
            ForEach(viewModel.availableLetters) { tile in
                letterTileView(
                    tile: tile,
                    backgroundColor: tile.type == .consonant ? tutorialConsonantColor : tutorialVowelColor,
                    textColor: .white,
                    isDraggable: true,
                    isTutorial: false
                )
            }
        }
        .padding(.horizontal, 20)
        .frame(maxHeight: viewModel.availableLetters.count > 4 ? 130 : (viewModel.availableLetters.isEmpty ? 0 : 65))
    }
}

// MARK: - Preview
#if DEBUG
struct SyllableView_Previews: PreviewProvider {
    // Helper function to create and configure view models for previews
    static func createViewModel(tutorialPage: Int? = nil, showTutorialOverride: Bool = true) -> SyllableViewModel {
        let appStateManager = AppStateManager() // Ensure AppStateManager is available for previews
        let levelDef = LevelDefinition(id: 2, position: .zero, range: "CV"..."CV", name: "Dunia Suku Kata") // Ensure LevelDefinition is available
        let vm = SyllableViewModel(appStateManager: appStateManager, levelDefinition: levelDef)
        
        vm.showTutorial = showTutorialOverride

        if let page = tutorialPage, showTutorialOverride {
            vm.currentTutorialPage = page
            // Call setup for the specific tutorial page if needed by your ViewModel
            vm.setupTutorialPageInteractions(pageId: page)
        } else if !showTutorialOverride {
            // Setup for main game
            vm.setupTask(.cv) // Assuming .cv is a valid task type
        } else if showTutorialOverride && tutorialPage == nil {
            // Default to the first tutorial page if not specified
            vm.currentTutorialPage = 0
            vm.setupTutorialPageInteractions(pageId: 0)
        }
        return vm
    }

    static var previews: some View {
        // Create view model instances first
        let vmPage0 = createViewModel(tutorialPage: 0)
        let vmPage1 = createViewModel(tutorialPage: 1)
        let vmPage2 = createViewModel(tutorialPage: 2)
        let vmPage3 = createViewModel(tutorialPage: 3)
        let vmMainGame = createViewModel(showTutorialOverride: false)

        // Explicitly return the Group to resolve ViewBuilder ambiguity
        return Group {
            SyllableView(viewModel: vmPage0)
                .previewDisplayName("Tutorial Page 1")
            SyllableView(viewModel: vmPage1)
                .previewDisplayName("Tutorial Page 2 (Static BA)")
            SyllableView(viewModel: vmPage2)
                .previewDisplayName("Tutorial Page 3 (Drag B)")
            SyllableView(viewModel: vmPage3)
                .previewDisplayName("Tutorial Page 4 (Drag A)")
            SyllableView(viewModel: vmMainGame)
                .previewDisplayName("Main Game (CV Task)")
        }
    }
}
#endif


// Helper for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (
                255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17
            )
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (
                int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF
            )
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB, red: Double(r) / 255, green: Double(g) / 255,
            blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// Revert to the previous version of slotTextColor, but it's not needed anymore
// with our new letterSlotView implementation that handles tile appearances directly
private extension SyllableView {
  func slotTextColor(
    for tile: SyllableViewModel.LetterTile,
    isTutorial: Bool
  ) -> Color {
    // 1) Was it the blue "B" in page 3?
    let isBlueB =
      isTutorial &&
      tile.letter == "B" &&
      viewModel.tutorialDraggable_B_ForPage3?.id == tile.id

    // 2) Was it the yellow "A" in page 2?
    let isYellowA =
      isTutorial &&
      tile.letter == "A" &&
      viewModel.tutorialStatic_A_ForPage2?.id == tile.id

    // 3) Was it the creamy "A" in page 4?
    let isCreamyA =
      isTutorial &&
      tile.letter == "A" &&
      viewModel.tutorialAvailableLetters_Page4
        .contains(where: { $0.id == tile.id })

    if isBlueB || isYellowA { return .white }
    if isCreamyA        { return tutorialAvailableTileTextColor }
    if isTutorial       { return tutorialAvailableTileTextColor }
    return .white
  }
}

// Helper extension to safely access array elements
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
