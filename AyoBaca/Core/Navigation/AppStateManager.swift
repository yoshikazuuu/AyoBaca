//
//  AppStateManager.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

import Combine
import SwiftData
import SwiftUI // Added for UIApplication if still needed, but we'll remove the AppDelegate part

class AppStateManager: ObservableObject {
    @Published var currentScreen: AppScreen = .splash
    @Published var onboardingCompleted: Bool = false
    @Published var userProfile: UserProfile?
    @Published var isLoading: Bool = true

    @Published var characterProgress = CharacterProgressManager()

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding =
        false

    @Published var currentStreak: Int = 0
    private var lastActivityDate: Date?
    private let streakKey = "userStreakCount"
    private let lastActivityDateKey = "lastActivityDate"

    @Published var currentLearningCharacter: String?
    private let currentLearningCharacterKey = "currentLearningCharacter"

    private var cancellables = Set<AnyCancellable>()

    let mainAlphabetLevelDefinition = LevelDefinition(
        id: 1,
        position: CGPoint(x: 0.2, y: 0.75),
        range: "A"..."Z",
        name: "Pulau Alfabet (A-Z)"
    )

    init() {
        self.onboardingCompleted = hasCompletedOnboarding
        self.currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        self.lastActivityDate =
            UserDefaults.standard.object(forKey: lastActivityDateKey) as? Date
        self.currentLearningCharacter =
            UserDefaults.standard.string(forKey: currentLearningCharacterKey)

        if !hasCompletedOnboarding {
            self.currentLearningCharacter = nil
            UserDefaults.standard.removeObject(forKey: currentLearningCharacterKey)
        } else if self.currentLearningCharacter == nil && hasCompletedOnboarding {
            let nextChar = characterProgress.getNextCharacterToLearn()
            self.currentLearningCharacter = nextChar
            print("Initial currentLearningCharacter set to: \(nextChar)")
        }
        checkAndResetStreakIfNeeded()
    }

    @MainActor
    func setCurrentLearningCharacter(_ character: String?) {
        guard currentLearningCharacter != character else { return }

        currentLearningCharacter = character
        if let char = character {
            UserDefaults.standard.set(char, forKey: currentLearningCharacterKey)
            print("Saved currentLearningCharacter: \(char)")
        } else {
            UserDefaults.standard.removeObject(forKey: currentLearningCharacterKey)
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
                if currentLearningCharacter == nil {
                    let nextChar = characterProgress.getNextCharacterToLearn()
                    self.currentLearningCharacter = nextChar
                    print(
                        "Setting initial currentLearningCharacter in checkOnboardingStatus: \(nextChar)"
                    )
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { self.currentScreen = .mainApp }
                }
            } else {
                setCurrentLearningCharacter(nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { self.currentScreen = .login }
                }
            }
        } catch {
            print("Error fetching user profiles: \(error)")
            setCurrentLearningCharacter(nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { self.currentScreen = .login }
            }
        }
        isLoading = false
    }

    @MainActor
    func completeOnboarding(with profile: UserProfile, in context: ModelContext) {
        context.insert(profile)
        do {
            try context.save()
            self.userProfile = profile
            self.onboardingCompleted = true
            hasCompletedOnboarding = true
            characterProgress.resetProgress()
            setCurrentLearningCharacter("A")
            withAnimation { self.currentScreen = .mainApp }
        } catch {
            print("Failed to save profile: \(error)")
        }
    }

    func checkAndResetStreakIfNeeded() {
        guard let lastDate = lastActivityDate else { return }
        let calendar = Calendar.current
        if !calendar.isDateInYesterday(lastDate)
            && !calendar.isDateInToday(lastDate)
        {
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

    @MainActor
    func recordActivityCompletion() {
        let calendar = Calendar.current
        let today = Date()
        guard let lastDate = lastActivityDate else {
            print("First activity recorded. Starting streak.")
            currentStreak = 1
            lastActivityDate = today
            saveStreakData()
            return
        }
        let startOfToday = calendar.startOfDay(for: today)
        let startOfLastDate = calendar.startOfDay(for: lastDate)
        let components = calendar.dateComponents(
            [.day], from: startOfLastDate, to: startOfToday)
        let dayDifference = components.day ?? 0

        if dayDifference == 0 {
            print(
                "Activity already recorded for today. Streak remains \(currentStreak)."
            )
        } else if dayDifference == 1 {
            currentStreak += 1
            lastActivityDate = today
            print(
                "Consecutive day activity! Streak increased to \(currentStreak)."
            )
            saveStreakData()
        } else {
            print(
                "Streak broken (last activity: \(lastDate), today: \(today)). Resetting streak."
            )
            currentStreak = 1
            lastActivityDate = today
            saveStreakData()
        }
    }

    @MainActor
    func saveOnboardingProfile(
        with profile: UserProfile, in context: ModelContext
    ) {
        context.insert(profile)
        do {
            try context.save()
            self.userProfile = profile
            hasCompletedOnboarding = true
            print("Profile saved, hasCompletedOnboarding flag set to true.")
        } catch {
            print("Failed to save profile: \(error)")
        }
    }

    @MainActor
    func finalizeOnboarding() {
        self.onboardingCompleted = true
        self.setCurrentLearningCharacter("A")
        withAnimation {
            self.currentScreen = .mainApp
        }
        print("Onboarding finalized. Navigating to MainApp.")
    }

    private func saveStreakData() {
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        UserDefaults.standard.set(lastActivityDate, forKey: lastActivityDateKey)
    }

    private func resetStreakCount() {
        currentStreak = 0
        lastActivityDate = nil
        saveStreakData()
    }

    // MODIFIED: resetOnboarding now takes ModelContext
    @MainActor func resetOnboarding(in context: ModelContext) {
        // Clear profile from SwiftData using the provided context
        do {
            try context.delete(model: UserProfile.self)
            // Optionally delete ReadingActivity as well if it should be cleared
            // try context.delete(model: ReadingActivity.self)
            try context.save()
            self.userProfile = nil // Clear local copy
            print("UserProfile data deleted during onboarding reset.")
        } catch {
            print("Error deleting UserProfile data during onboarding reset: \(error)")
        }

        hasCompletedOnboarding = false
        onboardingCompleted = false
        characterProgress.resetProgress()
        setCurrentLearningCharacter(nil)
        resetStreakCount()
        
        // Clear any other app-specific UserDefaults keys if necessary
        // UserDefaults.standard.removeObject(forKey: "someOtherAppSpecificKey")

        withAnimation {
            currentScreen = .login // Or .splash, depending on desired flow
        }
        print("Onboarding has been reset.")
    }
    

    #if DEBUG
        @MainActor
        func debugResetStreak() {
            print("DEBUG: Resetting streak.")
            resetStreakCount()
        }
    #endif
}
