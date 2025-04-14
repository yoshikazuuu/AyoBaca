//
//  AppStateManager.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

import Combine
import SwiftData
import SwiftUI

class AppStateManager: ObservableObject {
    // Published properties for reactive UI updates
    @Published var currentScreen: AppScreen = .splash
    @Published var onboardingCompleted: Bool = false
    @Published var userProfile: UserProfile?
    @Published var isLoading: Bool = true

    @Published var characterProgress = CharacterProgressManager()

    // Use AppStorage to persist onboarding state
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding =
        false

    // Streak Data
    @Published var currentStreak: Int = 0
    private var lastActivityDate: Date?
    private let streakKey = "userStreakCount"
    private let lastActivityDateKey = "lastActivityDate"

    // Continuous Learning Character
    @Published var currentLearningCharacter: String?
    private let currentLearningCharacterKey = "currentLearningCharacter"

    // Keep track of any subscriptions
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Load onboarding state from AppStorage
        self.onboardingCompleted = hasCompletedOnboarding
        self.currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        self.lastActivityDate =
            UserDefaults.standard.object(
                forKey: lastActivityDateKey) as? Date

        // --- Load current learning character ---
        self.currentLearningCharacter = UserDefaults.standard.string(
            forKey: currentLearningCharacterKey)
        // If onboarding isn't complete, ensure no character is set
        if !hasCompletedOnboarding {
            self.currentLearningCharacter = nil
            UserDefaults.standard.removeObject(
                forKey: currentLearningCharacterKey)
        } else if self.currentLearningCharacter == nil && hasCompletedOnboarding
        {
            // If onboarding is done but no character is set, default to the next one after 'A'
            // or 'A' itself if nothing is unlocked yet.
            let nextChar = characterProgress.getNextCharacterToLearn()
            self.currentLearningCharacter = nextChar
            // Don't save this default here, let activities save it explicitly.
            print("Initial currentLearningCharacter set to: \(nextChar)")
        }
        // --- End Loading ---

        // Initial check if streak should be reset (e.g., if last activity was before yesterday)
        checkAndResetStreakIfNeeded()
    }

    @MainActor
    func setCurrentLearningCharacter(_ character: String?) {
        // Only update if the value actually changes
        guard currentLearningCharacter != character else { return }

        currentLearningCharacter = character
        if let char = character {
            UserDefaults.standard.set(char, forKey: currentLearningCharacterKey)
            print("Saved currentLearningCharacter: \(char)")
        } else {
            UserDefaults.standard.removeObject(
                forKey: currentLearningCharacterKey)
            print("Cleared currentLearningCharacter")
        }
    }

    @MainActor
    func checkOnboardingStatus(in context: ModelContext) {
        isLoading = true
        let descriptor = FetchDescriptor<UserProfile>(sortBy: [
            SortDescriptor(\.lastUpdated, order: .reverse)
        ])

        do {
            let profiles = try context.fetch(descriptor)
            if let profile = profiles.first, hasCompletedOnboarding {
                self.userProfile = profile
                self.onboardingCompleted = true
                // --- Set initial learning character if needed ---
                if currentLearningCharacter == nil {
                    let nextChar = characterProgress.getNextCharacterToLearn()
                    // Don't save here, just set for the session start
                    self.currentLearningCharacter = nextChar
                    print(
                        "Setting initial currentLearningCharacter in checkOnboardingStatus: \(nextChar)"
                    )
                }
                // --- End Setting ---
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { self.currentScreen = .mainApp }
                }
            } else {
                // Onboarding not complete, clear learning character state
                setCurrentLearningCharacter(nil)  // Ensure it's cleared
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { self.currentScreen = .login }
                }
            }
        } catch {
            print("Error fetching user profiles: \(error)")
            setCurrentLearningCharacter(nil)  // Ensure it's cleared on error
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { self.currentScreen = .login }
            }
        }
        isLoading = false
    }

    @MainActor
    func completeOnboarding(with profile: UserProfile, in context: ModelContext)
    {
        context.insert(profile)
        do {
            try context.save()
            self.userProfile = profile
            self.onboardingCompleted = true
            hasCompletedOnboarding = true

            // --- Set initial learning character after onboarding ---
            characterProgress.resetProgress()  // Start fresh
            setCurrentLearningCharacter("A")  // Start with A after onboarding
            // --- End Setting ---

            withAnimation { self.currentScreen = .mainApp }
        } catch {
            print("Failed to save profile: \(error)")
        }
    }

    func checkAndResetStreakIfNeeded() {
        guard let lastDate = lastActivityDate else {
            // No previous activity, streak is already 0 (or whatever default)
            return
        }

        // Use Calendar to compare dates, ignoring time
        let calendar = Calendar.current
        if !calendar.isDateInYesterday(lastDate)
            && !calendar.isDateInToday(lastDate)
        {
            // Last activity was before yesterday, reset streak
            print(
                "Streak reset: Last activity was on \(lastDate), which is before yesterday."
            )
            resetStreakCount()
        } else {
            print(
                "Streak maintained: Last activity was on \(lastDate) (today or yesterday)."
            )
        }
    }

    /// Call this function when the user completes a designated daily activity (e.g., Writing).
    @MainActor  // Ensure UI updates happen on the main thread
    func recordActivityCompletion() {
        let calendar = Calendar.current
        let today = Date()

        guard let lastDate = lastActivityDate else {
            // First activity ever
            print("First activity recorded. Starting streak.")
            currentStreak = 1
            lastActivityDate = today
            saveStreakData()
            return
        }

        // Compare using start of day to ignore time component
        let startOfToday = calendar.startOfDay(for: today)
        let startOfLastDate = calendar.startOfDay(for: lastDate)

        let components = calendar.dateComponents(
            [.day], from: startOfLastDate, to: startOfToday)
        let dayDifference = components.day ?? 0

        if dayDifference == 0 {
            // Activity already completed today, do nothing
            print(
                "Activity already recorded for today. Streak remains \(currentStreak)."
            )
        } else if dayDifference == 1 {
            // Consecutive day activity
            currentStreak += 1
            lastActivityDate = today
            print(
                "Consecutive day activity! Streak increased to \(currentStreak)."
            )
            saveStreakData()
        } else {
            // Missed one or more days
            print(
                "Streak broken (last activity: \(lastDate), today: \(today)). Resetting streak."
            )
            currentStreak = 1  // Start a new streak
            lastActivityDate = today
            saveStreakData()
        }
    }

    private func saveStreakData() {
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        UserDefaults.standard.set(lastActivityDate, forKey: lastActivityDateKey)
    }

    // Resets the streak count to 0 and clears the last activity date.
    private func resetStreakCount() {
        currentStreak = 0
        lastActivityDate = nil  // Clear the date as well
        saveStreakData()  // Persist the reset
    }

    @MainActor func resetOnboarding() {
        // For testing - resets onboarding state
        hasCompletedOnboarding = false
        onboardingCompleted = false
        characterProgress.resetProgress()
        setCurrentLearningCharacter(nil)

        resetStreakCount()

        withAnimation {
            currentScreen = .login
        }
    }

    #if DEBUG
        @MainActor
        func debugResetStreak() {
            print("DEBUG: Resetting streak.")
            resetStreakCount()
        }
    #endif
}
