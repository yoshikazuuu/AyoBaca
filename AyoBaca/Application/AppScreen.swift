//
//  AppScreen.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

enum AppScreen: Equatable {
    // Existing screens
    case splash
    case login
    case welcome
    case nameSetup
    case ageSetup
    case onboardingIntro1
    case onboardingIntro2

    // Main application screens
    case mainApp
    case levelMap
    case profile

    // New Learning Activity Screens
    case characterSelection(levelId: Int)
    case spellingActivity(character: String)
    case writingActivity(character: String)
}
