import SwiftUI
import UniformTypeIdentifiers  // For onDrop

struct SyllableView: View {
    @StateObject var viewModel: SyllableViewModel

    // Define consistent colors for all tiles
    private let tileBgColor = Color(hex: "#F3EAD3")  // Creamy color for all tiles
    private let tileTextColor = Color(hex: "#78350F")  // Brownish text for all tiles
    private let mainBackgroundColor = Color(hex: "#A1CC49")  // Light Green background

    var body: some View {
        ZStack {
            mainBackgroundColor.ignoresSafeArea()
            // Mascot Placeholder
            if viewModel.currentTutorialPage == 0
                || viewModel.currentTutorialPage == 1
                || viewModel.currentTutorialPage == 2
            {
                VStack {
                    Spacer()
                    Image("leveltwo-mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350)
                }.ignoresSafeArea()
            }

            if viewModel.showTutorial {
                tutorialView(
                    for: viewModel.tutorialContents[
                        viewModel.currentTutorialPage])
            } else {
                mainActivityView
            }
        }
        // Apply animations at a higher level for smoother transitions
        .animation(
            .spring(response: 0.4, dampingFraction: 0.8),
            value: viewModel.showTutorial
        )
        .animation(
            .spring(response: 0.4, dampingFraction: 0.8),
            value: viewModel.currentTutorialPage
        )
        .animation(
            .easeInOut(duration: 0.3), value: viewModel.isTutorialStepCorrect
        )
        .animation(
            .easeInOut(duration: 0.3), value: viewModel.isCorrectCombination
        )
        .animation(
            .easeInOut(duration: 0.3), value: viewModel.tutorialFeedbackMessage
        )
        .animation(.easeInOut(duration: 0.3), value: viewModel.feedbackMessage)
        .animation(.easeInOut(duration: 0.3), value: viewModel.slotLetters)  // Add animation for slot letter changes
    }

    // MARK: - Main Activity View
    @ViewBuilder
    private var mainActivityView: some View {
        GeometryReader { geometry in
            VStack {
                mainBackButton.padding([.leading, .top])

                Spacer()  // Add spacer to push content to center

                VStack(spacing: 15) {
                    Text(viewModel.currentTaskType.instructions)
                        .font(.appFont(.rethinkRegular, size: 18))
                        .foregroundColor(tileTextColor)
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
                    .background(contentBoxBackground(height: 100))
                    .padding(.horizontal)

                    if viewModel.isCorrectCombination == true {
                        soundButton(action: viewModel.playSound)
                    } else {
                        Color.clear.frame(height: 50)  // Placeholder for sound button
                    }

                    if !viewModel.feedbackMessage.isEmpty {
                        feedbackMessageView(
                            text: viewModel.feedbackMessage,
                            isCorrect: viewModel.isCorrectCombination == true
                        )
                    } else {
                        Color.clear.frame(height: 40)  // Placeholder for feedback
                    }

                    availableLetterTilesGrid_MainGame.padding(.vertical, 10)

                    if viewModel.showNextButton {
                        nextButton(
                            title: "Selanjutnya", action: viewModel.nextTask)
                    } else {
                        Color.clear.frame(height: 50)  // Placeholder for next button
                    }
                }

                Spacer()  // Add spacer to push content to center
            }
            .frame(width: geometry.size.width)
        }
    }

    // MARK: - Tutorial View
    @ViewBuilder
    private func tutorialView(
        for content: SyllableViewModel.TutorialPageContent
    ) -> some View {
        GeometryReader { geometry in
            VStack {
                mainBackButton.padding([.leading, .top])

                Spacer(minLength: 20)  // Add spacer to push content toward center

                VStack(spacing: 10) {
                    if content.showMainSpeakerButton {
                        soundButton {
                            viewModel.playTutorialSound(pageIndex: content.id)
                        }
                        .scaleEffect(1.2)  // Make tutorial speaker slightly larger
                    }

                    Text(content.instructionText)
                        .font(.appFont(.rethinkRegular, size: 18))
                        .foregroundColor(tileTextColor)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(contentBoxBackground())
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)  // Allow text to wrap

                    // --- Interactive/Display Tutorial Content Area ---
                    Group {
                        if content.id == 1 {  // Page 2: "Sila adalah..." - Static B and A example
                            tutorialPage2DisplayContent(content: content)
                        } else if content.id == 2 {  // Page 3: "Susun huruf..." - User drags 'B'
                            tutorialPage3DragBContent(content: content)
                        } else if content.id == 3 {  // Page 4: "Sekarang, geser A..." - 'B' pre-filled, user drags 'A'
                            tutorialPage4DragAContent(content: content)
                        } else {  // Default for page 1 or any other non-interactive page
                            Color.clear.frame(minHeight: 120)  // Placeholder
                        }
                    }
                    .padding(.vertical, 5)
                    .frame(minHeight: 120)

                    if !viewModel.tutorialFeedbackMessage.isEmpty {
                        feedbackMessageView(
                            text: viewModel.tutorialFeedbackMessage,
                            isCorrect: viewModel.isTutorialStepCorrect == true
                        )
                    } else {
                        Color.clear.frame(height: 30)  // Placeholder for feedback
                    }

                    // Show bottom tiles only on page 4 (index 3) for dragging 'A'
                    if content.showBottomTilesInteractionArea && content.id == 3
                    {
                        tutorialBottomLetterTiles_ForPage4().padding(.bottom, 5)
                    } else {
                        Color.clear.frame(height: 100)  // Placeholder if no bottom tiles
                    }

                    nextButton(title: content.bottomButtonText) {
                        if content.id == viewModel.tutorialPagesCount - 1 {  // Last tutorial page
                            viewModel.startActivity()
                        } else {
                            viewModel.nextTutorialPage()
                        }
                    }
                    .padding(.bottom, 10)
                }

                Spacer()  // Add spacer to push content toward center
            }
            .frame(width: geometry.size.width)
            .onAppear {
                // Setup interactions specific to this tutorial page when it appears
                viewModel.setupTutorialPageInteractions(pageId: content.id)
            }
        }
    }

    // MARK: - Tutorial Sub-components (Interactive & Display)

    @ViewBuilder
    private func tutorialPage2DisplayContent(
        content: SyllableViewModel.TutorialPageContent
    ) -> some View {
        // Page 2 (index 1 in tutorialContents): "Sila adalah..." - Shows static B and A example.
        VStack(spacing: 10) {
            Text(content.examplePrimaryText ?? "contoh:")
                .font(.appFont(.dylexicBold, size: 18))
                .foregroundColor(tileTextColor)
            HStack(spacing: 10) {
                // Static 'B' tile for display
                if let bTile = viewModel.tutorialDraggable_B_ForPage3 {  // Re-use the B tile definition
                    letterTileView(
                        tile: bTile,
                        backgroundColor: tileBgColor,
                        textColor: tileTextColor,
                        isDraggable: false,
                        isTutorial: true)
                }
                // Static 'A' tile for display
                if let aTile = viewModel.tutorialStatic_A_ForPage2 {
                    letterTileView(
                        tile: aTile,
                        backgroundColor: tileBgColor,
                        textColor: tileTextColor,
                        isDraggable: false,
                        isTutorial: true)
                }
            }
            if let hint = content.exampleSoundAccessibilityHint {
                tutorialSoundHint(hintText: hint) {
                    viewModel.playTutorialSound(pageIndex: content.id)
                }
            }
        }
        .padding()
        .background(contentBoxBackground(height: 180))
        .padding(.horizontal)
    }

    @ViewBuilder
    private func tutorialPage3DragBContent(
        content: SyllableViewModel.TutorialPageContent
    ) -> some View {
        // Page 3 (index 2 in tutorialContents): "Susun huruf..." - User drags 'B' into the first slot.
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                // Draggable "B" area OR "B" in slot
                if let bTile = viewModel.tutorialDraggable_B_ForPage3 {  // If B is still available to drag
                    letterTileView(
                        tile: bTile,
                        backgroundColor: tileBgColor,
                        textColor: tileTextColor,
                        isDraggable: true,
                        isTutorial: true)
                } else {  // B has been dragged into the slot
                    letterSlotView(
                        tile: viewModel.tutorialSlotLetters[safe: 0] ?? nil,
                        isTutorial: true,
                        slotIndex: 0,
                        isCorrect: viewModel.isTutorialStepCorrect
                    )
                }
                // Empty second slot (visual only for this page, not a drop target yet)
                letterSlotView(
                    tile: nil, isTutorial: true, slotIndex: 1, isCorrect: nil)  // isCorrect is nil as it's not part of this step's validation
            }
            if let hint = content.exampleSoundAccessibilityHint {
                tutorialSoundHint(hintText: hint, isSpeakerDisabled: true) {}  // Speaker disabled until BA formed on next page
            }
        }
        .padding()
        .background(contentBoxBackground(height: 150))
        .padding(.horizontal)
    }

    @ViewBuilder
    private func tutorialPage4DragAContent(
        content: SyllableViewModel.TutorialPageContent
    ) -> some View {
        // Page 4 (index 3 in tutorialContents): "Sekarang, geser A..." - 'B' is pre-filled, user drags 'A'.
        VStack(spacing: 10) {
            if let primaryText = content.examplePrimaryText {  // "Selamat mencoba!"
                Text(primaryText)
                    .font(.appFont(.dylexicBold, size: 18))
                    .foregroundColor(tileTextColor)
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
            if viewModel.showTutorialSyllableSpeaker {  // If "BA" is correctly formed
                soundButton(
                    action: viewModel.playTutorialConstructedSyllableSound)
            } else if content.exampleSoundAccessibilityHint != nil {  // General hint for this page
                tutorialSoundHint(
                    hintText: "Geser 'A' untuk melengkapi 'BA'.",
                    isSpeakerDisabled: true
                ) {}
            }
        }
        .padding()
        .background(
            contentBoxBackground(
                height: viewModel.showTutorialSyllableSpeaker ? 200 : 150)
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    private func tutorialBottomLetterTiles_ForPage4() -> some View {
        // These are for tutorial page 4 (index 3), where 'A' is draggable.
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 10), count: 3),  // 3 columns
            spacing: 10
        ) {
            ForEach(viewModel.tutorialAvailableLetters_Page4) { tile in
                letterTileView(
                    tile: tile,
                    backgroundColor: tileBgColor,
                    textColor: tileTextColor,
                    isDraggable: tile.letter == "A",  // Only 'A' is draggable on this page
                    isTutorial: true
                )
            }
        }
        .padding(.horizontal, 40)  // Adjust padding for centering
        .frame(maxHeight: 140)  // Enough for 2 rows of 3 tiles
    }

    @ViewBuilder
    private func tutorialSoundHint(
        hintText: String, isSpeakerDisabled: Bool = false,
        action: @escaping () -> Void = {}
    ) -> some View {
        HStack(spacing: 8) {
            Button(action: action) {
                Image(
                    systemName: isSpeakerDisabled
                        ? "speaker.slash.fill" : "speaker.wave.2.fill"
                )
                .font(.system(size: 20))
                .foregroundColor(
                    isSpeakerDisabled ? .gray.opacity(0.6) : .white
                )
                .padding(8)
                .background(
                    Circle().fill(
                        isSpeakerDisabled
                            ? Color.white.opacity(0.5)
                            : Color("AppOrange").opacity(0.8)))
            }.disabled(isSpeakerDisabled)
            Text(hintText)
                .font(.appFont(.rethinkRegular, size: 12))
                .foregroundColor(tileTextColor.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)  // Allow text to wrap
                .lineLimit(2)
        }
        .padding(.horizontal, 5)  // Minimal horizontal padding for the hint itself
    }

    // MARK: - Shared UI Components
    @ViewBuilder
    private var mainBackButton: some View {
        HStack {
            Button {
                viewModel.navigateBack()
            } label: {
                Text("Kembali")
                    .font(.appFont(.rethinkBold, size: 16))
                    .foregroundColor(Color("AppOrange"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(Color.white.opacity(0.9)).shadow(
                            color: .black.opacity(0.1), radius: 2))
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func soundButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 24))
                .foregroundColor(Color("AppOrange"))  // Orange speaker icon
                .padding(12)
                .background(
                    Circle().fill(Color.white).shadow(
                        color: .black.opacity(0.1), radius: 2))
        }
        .frame(height: 50)  // Consistent height
    }

    @ViewBuilder
    private func feedbackMessageView(text: String, isCorrect: Bool) -> some View
    {
        Text(text)
            .font(.appFont(.rethinkRegular, size: 14))
            .foregroundColor(
                isCorrect ? Color.green.opacity(0.9) : Color.red.opacity(0.9)
            )
            .padding(8)
            .background(Color.white.opacity(0.8).cornerRadius(10))
            .shadow(color: .black.opacity(0.05), radius: 1)
            .frame(minHeight: 30)  // Ensure it has some height even if text is short
            .padding(.horizontal)
    }

    @ViewBuilder
    private func nextButton(title: String, action: @escaping () -> Void)
        -> some View
    {
        Button(action: action) {
            Text(title)
                .font(.appFont(.rethinkBold, size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    Capsule().fill(Color("AppOrange")).shadow(
                        color: .black.opacity(0.15), radius: 2, y: 1))
        }
        .frame(height: 50)  // Consistent height
    }

    @ViewBuilder
    private func contentBoxBackground(height: CGFloat? = nil) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        Color("AppOrange").opacity(0.5),
                        style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            )
            .frame(height: height)  // Optional fixed height
    }

    // Generic Letter Tile View (Used by tutorial and main game)
    @ViewBuilder
    private func letterTileView(
        tile: SyllableViewModel.LetterTile, backgroundColor: Color,
        textColor: Color, isDraggable: Bool, isTutorial: Bool
    ) -> some View {
        Text(tile.letter)
            .font(.appFont(.dylexicBold, size: 36))
            .foregroundColor(textColor)
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.1), radius: 1)
            )
            .overlay(  // Dashed border for all tiles
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        Color("AppOrange").opacity(0.5),
                        style: StrokeStyle(lineWidth: 2, dash: [4, 3])
                    )
            )
            .onDrag {
                if isDraggable {
                    return NSItemProvider(object: tile.letter as NSString)
                }
                return NSItemProvider()  // Non-draggable
            }
    }

    // Generic Letter Slot View (Used by tutorial and main game)
    @ViewBuilder
    private func letterSlotView(
        tile: SyllableViewModel.LetterTile?, isTutorial: Bool, slotIndex: Int,
        isCorrect: Bool?
    ) -> some View {
        ZStack {
            // Only show border if slot is empty
            if tile == nil {
                let baseBorderColor: Color =
                    isCorrect == false
                    ? Color.red.opacity(0.6)
                    : Color("AppOrange").opacity(0.7)

                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        baseBorderColor,
                        style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                    )
                    .frame(width: 70, height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.6))
                    )
            } else {
                // No border, just background
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 70, height: 70)
            }

            if let currentTile = tile {
                // Display the letter in with consistent styling
                Text(currentTile.letter)
                    .font(.appFont(.dylexicBold, size: 36))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                viewModel.vowels.contains(currentTile.letter)
                                    ? Color(red: 1, green: 0.77, blue: 0.13)
                                    : Color(red: 0.39, green: 0.66, blue: 0.88))
                    )
            }
        }
        .overlay(
            isCorrect == true
                ? RoundedRectangle(cornerRadius: 15).stroke(
                    Color.green.opacity(0.9), lineWidth: 3) : nil
        )
        .onDrop(of: [UTType.text], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            provider.loadObject(ofClass: NSString.self) { item, _ in
                if let letterString = item as? String {
                    DispatchQueue.main.async {
                        var tileToDrop: SyllableViewModel.LetterTile?
                        if isTutorial {
                            if viewModel.currentTutorialPage == 2
                                && letterString == "B"
                            {
                                tileToDrop =
                                    viewModel.tutorialDraggable_B_ForPage3
                            } else if viewModel.currentTutorialPage == 3
                                && letterString == "A"
                            {
                                tileToDrop = viewModel
                                    .tutorialAvailableLetters_Page4.first {
                                        $0.letter == "A"
                                    }
                            }
                            if let tile = tileToDrop {
                                viewModel.handleTutorialDrop(
                                    droppedTile: tile, slotIndex: slotIndex)
                            }
                        } else {
                            viewModel.handleDrop(
                                letter: letterString, at: slotIndex)
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
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 10),
                count: viewModel.availableLetters.count > 4
                    ? 4 : max(1, viewModel.availableLetters.count)),
            spacing: 10
        ) {
            ForEach(viewModel.availableLetters) { tile in
                letterTileView(
                    tile: tile,
                    backgroundColor: tileBgColor,
                    textColor: tileTextColor,
                    isDraggable: true,
                    isTutorial: false
                )
            }
        }
        .padding(.horizontal, 20)
        .frame(
            maxHeight: viewModel.availableLetters.count > 4
                ? 130 : (viewModel.availableLetters.isEmpty ? 0 : 65))
    }
}

// MARK: - Preview
#if DEBUG
    struct SyllableView_Previews: PreviewProvider {
        // Helper function to create and configure view models for previews
        static func createViewModel(
            tutorialPage: Int? = nil, showTutorialOverride: Bool = true
        ) -> SyllableViewModel {
            let appStateManager = AppStateManager()
            let levelDef = LevelDefinition(
                id: 2, position: .zero, range: "CV"..."CV",
                name: "Dunia Suku Kata")
            let vm = SyllableViewModel(
                appStateManager: appStateManager, levelDefinition: levelDef)

            vm.showTutorial = showTutorialOverride

            if let page = tutorialPage, showTutorialOverride {
                vm.currentTutorialPage = page
                vm.setupTutorialPageInteractions(pageId: page)
            } else if !showTutorialOverride {
                vm.setupTask(.cv)
            } else if showTutorialOverride && tutorialPage == nil {
                vm.currentTutorialPage = 0
                vm.setupTutorialPageInteractions(pageId: 0)
            }
            return vm
        }

        static var previews: some View {
            let vmPage0 = createViewModel(tutorialPage: 0)
            let vmPage1 = createViewModel(tutorialPage: 1)
            let vmPage2 = createViewModel(tutorialPage: 2)
            let vmPage3 = createViewModel(tutorialPage: 3)
            let vmMainGame = createViewModel(showTutorialOverride: false)

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

// Helper extension to safely access array elements
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
