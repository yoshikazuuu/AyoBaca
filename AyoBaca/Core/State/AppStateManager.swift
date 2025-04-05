//
//  AppStateManager.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//


import SwiftUI
import SwiftData
import Combine

class AppStateManager: ObservableObject {
    // Published properties for reactive UI updates
    @Published var currentScreen: AppScreen = .splash
    @Published var onboardingCompleted: Bool = false
    @Published var userProfile: UserProfile?
    @Published var isLoading: Bool = true
    
    // Use AppStorage to persist onboarding state
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // Keep track of any subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load onboarding state from AppStorage
        self.onboardingCompleted = hasCompletedOnboarding
    }
    
    @MainActor
    func checkOnboardingStatus(in context: ModelContext) {
        // Start with loading state
        isLoading = true
        
        // Check if we have any user profiles
        let descriptor = FetchDescriptor<UserProfile>(sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)])
        
        do {
            let profiles = try context.fetch(descriptor)
            
            // If we have a profile and onboarding is marked complete
            if let profile = profiles.first, hasCompletedOnboarding {
                self.userProfile = profile
                self.onboardingCompleted = true
                
                // After splash, go to main app
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.currentScreen = .mainApp
                    }
                }
            } else {
                // No profile or onboarding not complete - go to login/onboarding
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.currentScreen = .login
                    }
                }
            }
        } catch {
            print("Error fetching user profiles: \(error)")
            // Handle error - default to onboarding
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.currentScreen = .login
                }
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func completeOnboarding(with profile: UserProfile, in context: ModelContext) {
        // Save profile to SwiftData
        context.insert(profile)
        
        // Try to save immediately
        do {
            try context.save()
            
            // Update our state
            self.userProfile = profile
            self.onboardingCompleted = true
            
            // Persist the onboarding flag
            hasCompletedOnboarding = true
            
            // Navigate to main app
            withAnimation {
                self.currentScreen = .mainApp
            }
        } catch {
            print("Failed to save profile: \(error)")
            // Handle error (show alert, etc.)
        }
    }
    
    func resetOnboarding() {
        // For testing - resets onboarding state
        hasCompletedOnboarding = false
        onboardingCompleted = false
        
        withAnimation {
            currentScreen = .login
        }
    }
}
