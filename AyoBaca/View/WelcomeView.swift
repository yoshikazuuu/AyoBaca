import SwiftUI

struct WelcomeView: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var onboardingState: OnboardingState
    @State private var animateTitle = false
    @State private var animateText = false
    @State private var animateButton = false
    @State private var animateMascot = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppOrange").ignoresSafeArea()
                
                // Animated floating elements in background
                ForEach(0..<8) { index in
                    Image(systemName: ["book.fill", "pencil", "highlighter", "text.book.closed.fill", "abc"].randomElement()!)
                        .font(.system(size: CGFloat.random(in: 20...40)))
                        .foregroundColor(.white.opacity(0.1))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .offset(y: animateTitle ? CGFloat.random(in: -20...20) : 0)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...5))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: animateTitle
                        )
                }
                
                VStack(spacing: 0) {
                    VStack(spacing: -30) {
                        Text("AYO")
                            .font(.appFont(.dylexicBold, size: 40))
                            .foregroundColor(.white)
                        Text("BACA")
                            .font(.appFont(.dylexicBold, size: 40))
                            .foregroundColor(.white)
                    }
                    .opacity(animateTitle ? 1 : 0)
                    .offset(y: animateTitle ? 0 : 30)
                    
                    Text("Halo, Ayah dan Bunda!")
                        .font(.appFont(.rethinkBold, size: 24))
                        .foregroundColor(.white)
                        .opacity(animateText ? 1 : 0)
                        .offset(y: animateText ? 0 : 20)
                    
                    Text("Aplikasi ini dirancang khusus untuk anak-anak dengan kesulitan membaca agar mereka lebih percaya diri dan semangat belajar.")
                        .font(.appFont(.rethinkRegular, size: 17))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(animateText ? 1 : 0)
                        .offset(y: animateText ? 0 : 20)
                    
                    Button {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            currentScreen = .nameSetup
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Lanjut ke")
                                .font(.appFont(.rethinkBold, size: 16))
                            Text("Profile Set-up")
                                .font(.appFont(.rethinkItalic, size: 16))
                        }
                        .foregroundColor(Color("AppOrange"))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                    .padding(.top, 30)
                    .scaleEffect(animateButton ? 1 : 0.8)
                    .opacity(animateButton ? 1 : 0)
                    
                    // Add progress indicator
                    OnboardingProgressView(currentStep: 1, totalSteps: 4)
        
                    
                    Image("mascot-hi")
                        .scaledToFit()
                        .frame(height: geometry.size.height * 0.45)
                        .offset(x: animateMascot ? -10 : -100, y: 150)
                        .opacity(animateMascot ? 1 : 0)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            onboardingState.animateContent = false
            onboardingState.animateMascot = false
            
            // Sequence the animations
            withAnimation(.easeOut(duration: 0.7)) {
                animateTitle = true
            }
            
            withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
                animateText = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.5)) {
                animateButton = true
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                animateMascot = true
            }
        }
    }
}

#Preview {
    WelcomeView(currentScreen: .constant(.welcome))
        .environmentObject(OnboardingState())
}
