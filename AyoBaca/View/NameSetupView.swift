import SwiftUI

struct NameSetupView: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var onboardingState: OnboardingState
    @State private var animateTitle = false
    @State private var animateTextField = false
    @State private var animateButton = false
    @State private var animateMascot = false
    @FocusState private var isTextFieldFocused: Bool // Keep FocusState

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea()
                    // Add tap gesture to dismiss keyboard anywhere on the background
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                
                FloatingAlphabetBackground(count: 25, fontStyle: .dylexicRegular)

                VStack(spacing: 20) {
                    // Back button row
                    HStack {
                        Button {
                            isTextFieldFocused = false // Dismiss keyboard on back
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                currentScreen = .welcome
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(.white.opacity(0.2)))
                        }
                        .padding(.leading, 20)

                        Spacer()
                    }
                    .padding(.top, 10)

                    Spacer()

                    // Title
                    Text("Nama Anak")
                        .font(.appFont(.rethinkExtraBold, size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(animateTitle ? 1 : 0)
                        .offset(y: animateTitle ? 0 : 20)

                    // Name input field
                    VStack {
                        TextField("Masukkan Nama Disini", text: $onboardingState.childName)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(25)
                            .foregroundColor(Color("AppOrange")) // Placeholder color
                            .accentColor(Color("AppOrange")) // Cursor color
                            .multilineTextAlignment(.center)
                            .font(.appFont(.rethinkBold, size: 24))
                            .focused($isTextFieldFocused) // Bind focus state
                            .submitLabel(.done) // Change return key to "Done"
                            .onSubmit {
                                // Action when return/done key is pressed
                                isTextFieldFocused = false // Dismiss keyboard
                                if !onboardingState.childName.isEmpty {
                                    // Optionally navigate directly on submit if desired
                                    // withAnimation {
                                    //     currentScreen = .ageSetup
                                    // }
                                }
                            }
                    }
                    .frame(height: 60)
                    .padding(.horizontal, 40)
                    .scaleEffect(animateTextField ? 1 : 0.8)
                    .opacity(animateTextField ? 1 : 0)

                    // Next button
                    Button {
                        isTextFieldFocused = false // Dismiss keyboard on button tap
                        if !onboardingState.childName.isEmpty {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                currentScreen = .ageSetup
                            }
                        }
                    } label: {
                        Text("Lanjut")
                            .font(.appFont(.rethinkRegular, size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("AppOrange"))
                            .padding()
                            .frame(width: 150)
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                    .opacity(onboardingState.childName.isEmpty ? 0.5 : 1.0)
                    .disabled(onboardingState.childName.isEmpty)
                    .scaleEffect(animateButton ? 1 : 0.8)
                    .opacity(animateButton ? 1 : 0)

                    // Progress indicator
                    OnboardingProgressView(currentStep: 2, totalSteps: 4)
                        .padding(.top, 10)

                    Spacer()

                    // Mascot and speech bubble
                    ZStack(alignment: .top) {
                        // Speech bubble only shows when mascot is animated
                        if animateMascot {
                            Text("Siapa nama kamu?")
                                .font(.appFont(.rethinkRegular, size: 16))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2) // Optional shadow for bubble
                                .offset(y: -60)
                                .transition(.scale.combined(with: .opacity))
                                .zIndex(1)
                        }

                        // Mascot image
                        Image("mascot")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 1)
                            .offset(y: animateMascot ? 0 : 150)
                            .opacity(animateMascot ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                }
                .padding(.vertical, 10)
                .frame(width: geometry.size.width) // Constrain to screen width
            }
        }
        .onAppear {
            // Sequence the animations
            withAnimation(.easeOut(duration: 0.5)) {
                animateTitle = true
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                animateTextField = true
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateButton = true
            }

            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.3)) {
                animateMascot = true
            }

            // Auto focus the text field slightly delayed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isTextFieldFocused = true
            }
        }
    }
}

// Helper extension (if not already defined elsewhere)
extension Double {
    func mapped(from: ClosedRange<Double>, to: ClosedRange<Double>) -> Double {
        let percentage = (self - from.lowerBound) / (from.upperBound - from.lowerBound)
        return to.lowerBound + percentage * (to.upperBound - to.lowerBound)
    }
}

// Preview (ensure OnboardingState is provided if needed)
#Preview {
    NameSetupView(currentScreen: .constant(.nameSetup))
        .environmentObject(OnboardingState()) // Add environment object for preview
}
