import SwiftUI

// MARK: - Main View

struct PronunciationHelperView: View {
    @StateObject var viewModel: PronunciationHelperViewModel

    var body: some View {
        ZStack {
            Color.backgroundOrange.ignoresSafeArea()
            backButton
            content
        }
        .navigationBarHidden(true)
    }

    // MARK: Subviews

    private var content: some View {
        VStack(spacing: 20) {
            Spacer()
            playButton
            Spacer()
            PronunciationCard(
                character: viewModel.currentCharacter,
                helperImageName: viewModel.helperImageName,
                sampleWord: viewModel.getSampleWord(
                    for: viewModel.currentCharacter
                ),
                onImageMissing: viewModel.helperImageName
            )
            Spacer()
            navigationButtons
                .padding(.bottom, 30)
        }
    }

    private var playButton: some View {
        Button(action: viewModel.playSound) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 50))
                .foregroundStyle(.white)
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 20) {
            navButton(
                systemName: "chevron.left.circle.fill",
                enabled: viewModel.canGoPrevious,
                action: viewModel.previousCharacter
            )
            Button("Mulai Latihan", action: viewModel.startPractice)
                .font(.appFont(.dylexicBold, size: 18))
                .foregroundColor(.appOrange)
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
            navButton(
                systemName: "chevron.right.circle.fill",
                enabled: viewModel.canGoNext,
                action: viewModel.nextCharacter
            )
        }
    }

    // Helper for consistent nav‐circle buttons
    private func navButton(
        systemName: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(enabled ? .white : .gray.opacity(0.5))
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
        }
        .disabled(!enabled)
    }

    private var backButton: some View {
        VStack {
            HStack {
                Button(action: viewModel.goBack) {
                    Image(systemName: "arrow.left")
                        .font(.title2.weight(.semibold))
                        .padding(12)
                        .background(Color.white.opacity(0.7))
                        .foregroundColor(.appOrange)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .padding([.top, .leading])
                Spacer()
            }
            Spacer()
        }
    }
}

// MARK: - Pronunciation Card

struct PronunciationCard: View {
    let character: String
    let helperImageName: String
    let sampleWord: String
    let onImageMissing: String

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(character)\(character.lowercased())")
                    .font(.appFont(.dylexicBold, size: 64))
                    .foregroundColor(.appOrange)
                Spacer()
            }

            Group {
                if let uiImage = UIImage(named: helperImageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    // Placeholder when asset is missing
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            Text("Image \(onImageMissing) missing")
                                .font(.caption)
                        )
                }
            }
            .frame(height: 200)
            .padding(.bottom, 10)

            HStack {
                Spacer()
                Text(sampleWord.capitalized(
                        with: Locale(identifier: "id_ID")
                     ))
                    .font(.appFont(.dylexicBold, size: 28))
                    .foregroundColor(.appOrange)
            }
        }
        .padding(30)
        .background(cardBackground)
        .padding(.horizontal, 30)
    }

    // Card background + dashed border
    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13.25)
                .fill(Color.cardBackground)
                .frame(width: 320.35, height: 420)
                .shadow(color: .black.opacity(0.25), radius: 1.33,
                        x: 0, y: 2.65)

            RoundedRectangle(cornerRadius: 12.22)
                .strokeBorder(
                    Color.cardStroke.opacity(0.42),
                    style: StrokeStyle(
                        lineWidth: 3.43,
                        dash: [13.74, 13.74]
                    )
                )
                .frame(width: 288.69, height: 381.82)
        }
    }
}

// MARK: - Color Extensions

private extension Color {
    static let backgroundOrange = Color(red: 0.94, green: 0.31, blue: 0.1)
    static let cardBackground   = Color(red: 1, green: 0.98, blue: 0.92)
    static let cardStroke       = Color(red: 0.94, green: 0.31, blue: 0.1)
}

// MARK: - Preview

struct PronunciationHelperView_Previews: PreviewProvider {
    static var previews: some View {
        let appStateManager = AppStateManager()
        let dummyLevel = LevelDefinition(
            id: 0,
            position: .zero,
            range: "A"..."C",
            name: "Dummy"
        )
        let vm = PronunciationHelperViewModel(
            appStateManager: appStateManager,
            character: "A",
            levelDefinition: dummyLevel
        )
        PronunciationHelperView(viewModel: vm)
    }
}
