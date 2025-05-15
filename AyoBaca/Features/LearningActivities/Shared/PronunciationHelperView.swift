import SwiftUI

struct PronunciationHelperView: View {
    @StateObject var viewModel: PronunciationHelperViewModel
    @EnvironmentObject var appStateManager: AppStateManager // If back button needs it directly, or use viewModel.goBack()

    var body: some View {
        ZStack {
            // Background Color (consistent with your app's theme)
            Color.orange.ignoresSafeArea() // Example color, adjust to your app's theme

            VStack(spacing: 20) {
                // Custom Back Button
                HStack {
                    Button(action: {
                        viewModel.goBack()
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Spacer()

                // Character and Image Card
                VStack {
                    Text(viewModel.currentCharacter)
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundColor(Color.primary.opacity(0.8))
                    
                    Image(viewModel.helperImageName) // e.g., "a-helper"
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding(.bottom, 10)
                        // Add a placeholder if the image is not found
                        .overlay {
                             // This is a basic placeholder. You might want a more specific one.
                             if UIImage(named: viewModel.helperImageName) == nil {
                                 Rectangle()
                                     .fill(Color.gray.opacity(0.1))
                                     .overlay(Text("Image for \(viewModel.helperImageName) missing").font(.caption))
                             }
                         }

                    Button(action: {
                        viewModel.playSound()
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .padding(15)
                            .background(Color.blue.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.9))
                        .shadow(radius: 10)
                )
                .padding(.horizontal, 30)

                Spacer()

                // Navigation and Practice Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.previousCharacter()
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(viewModel.canGoPrevious ? .white : .gray.opacity(0.5))
                    }
                    .disabled(!viewModel.canGoPrevious)

                    Button(action: {
                        viewModel.startPractice()
                    }) {
                        Text("Mulai Latihan")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding()
                            .frame(minWidth: 180)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }

                    Button(action: {
                        viewModel.nextCharacter()
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(viewModel.canGoNext ? .white : .gray.opacity(0.5))
                    }
                    .disabled(!viewModel.canGoNext)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

// Preview (Optional, but helpful)
// struct PronunciationHelperView_Previews: PreviewProvider {
//     static var previews: some View {
//         // You'll need to mock AppStateManager and LevelDefinition for the preview
//         let appStateManager = AppStateManager()
//         let dummyLevel = LevelDefinition(id: 0, position: .zero, range: "A"..."C", name: "Dummy Level")
//         let viewModel = PronunciationHelperViewModel(
//             appStateManager: appStateManager,
//             character: "A",
//             levelDefinition: dummyLevel
//         )
//         PronunciationHelperView(viewModel: viewModel)
//             .environmentObject(appStateManager)
//     }
// } 