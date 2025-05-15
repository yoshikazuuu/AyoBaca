//
//  LoginViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var rememberMe = false
    @Published var isPasswordVisible = false

    @Published var animateForm = false
    @Published var animateFields = false
    @Published var animateButtons = false

    // For @FocusState, the View still declares it, but ViewModel can control it
    // by publishing a property that the View's @FocusState binds to.
    // Or, the View can manage focus directly. For simplicity, we'll let View manage focus.

    private var appStateManager: AppStateManager

    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
    }

    func onAppearActions() {
        withAnimation(.easeOut(duration: 0.6)) {
            animateForm = true
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            animateFields = true
        }
        withAnimation(
            .spring(response: 0.6, dampingFraction: 0.7).delay(0.4)
        ) {
            animateButtons = true
        }
    }

    func loginTapped() {
        // Add simple validation if needed
        // if email.isEmpty || password.isEmpty { ... return }
        print("Log In Tapped: \(email), \(password)")
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            appStateManager.currentScreen = .welcome
        }
    }

    func signUpTapped() {
        print("Sign Up Tapped")
        // Navigate to sign up screen if you have one
        // appStateManager.currentScreen = .signUp
    }

    func forgotPasswordTapped() {
        print("Forgot Password Tapped")
        // Navigate to forgot password screen
    }

    func continueWithGoogle() {
        print("Continue with Google")
        // Implement Google Sign-In
    }

    func continueWithFacebook() {
        print("Continue with Facebook")
        // Implement Facebook Sign-In
    }
}
