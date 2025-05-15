//
//  DashboardViewModel.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import SwiftUI
import Combine
import SwiftData
import TipKit

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var childName: String = "Anak"
    @Published var childAge: Int = 0
    @Published var currentStreak: Int = 0
    // currentLearningCharacter is now primarily managed and observed from AppStateManager
    // @Published var currentLearningCharacter: String? = nil

    @Published var mainTips = TipGroup(.ordered) {
        ProfileTip()
        StreakTip()
        PracticeButtonTip()
        ProfileButtonTip()
    }

    private var appStateManager: AppStateManager
    private var cancellables = Set<AnyCancellable>()

    init(appStateManager: AppStateManager, modelContext: ModelContext? = nil) {
        self.appStateManager = appStateManager

        appStateManager.$userProfile
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.childName = profile.childName
                self?.childAge = profile.childAge
            }
            .store(in: &cancellables)

        appStateManager.$currentStreak
            .receive(on: DispatchQueue.main)
            .sink { [weak self] streak in
                self?.currentStreak = streak
            }
            .store(in: &cancellables)

        // No need to directly observe currentLearningCharacter here for a @Published var,
        // as AppStateManager is the source of truth and startPracticeTapped will use it.

        // Initial values
        self.childName = appStateManager.userProfile?.childName ?? "Anak"
        self.childAge = appStateManager.userProfile?.childAge ?? 0
        self.currentStreak = appStateManager.currentStreak
    }

    func mapButtonTapped() {
        appStateManager.currentScreen = .levelMap
    }

    func profileButtonTapped() {
        appStateManager.currentScreen = .profile
    }
}
