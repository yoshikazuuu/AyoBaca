//
//  SplashViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import SwiftData

@MainActor
class SplashViewModel: ObservableObject {
    @Published var animateTitle = false
    @Published var animateMascot = false

    private var appStateManager: AppStateManager
    private var modelContext: ModelContext

    init(appStateManager: AppStateManager, modelContext: ModelContext) {
        self.appStateManager = appStateManager
        self.modelContext = modelContext
    }

    func onAppear() {
        // Trigger animations
        withAnimation(.easeOut(duration: 0.8)) {
            animateTitle = true
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            animateMascot = true
        }

        // Start onboarding check
        // The delay for navigation is handled within AppStateManager
        appStateManager.checkOnboardingStatus(in: modelContext)
    }
}
