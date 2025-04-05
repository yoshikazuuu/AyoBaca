import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingState = OnboardingState()
    @State private var currentScreen: AppScreen = .splash
    
    var body: some View {
        ZStack {
            Color("AppOrange").ignoresSafeArea()
            
            switch currentScreen {
            case .splash:
                SplashView(currentScreen: $currentScreen)
                    .environmentObject(onboardingState)
                    .transition(.opacity)
            case .login:
                LoginView(currentScreen: $currentScreen)
                    .environmentObject(onboardingState)
                    .pageTransition()
            case .welcome:
                WelcomeView(currentScreen: $currentScreen)
                    .environmentObject(onboardingState)
                    .pageTransition()
            case .nameSetup:
                NameSetupView(currentScreen: $currentScreen)
                    .environmentObject(onboardingState)
                    .pageTransition()
            case .ageSetup:
                AgeSetupView(currentScreen: $currentScreen)
                    .environmentObject(onboardingState)
                    .pageTransition()
            case .mainApp:
                MainAppView(currentScreen: $currentScreen)
                    .environmentObject(onboardingState)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentScreen)
    }
}
