//
//  AppScreen.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

enum AppScreen: Equatable, Hashable {
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
    case characterSelection(levelDefinition: LevelDefinition)
    case spellingActivity(character: String, levelDefinition: LevelDefinition)
    case writingActivity(character: String, levelDefinition: LevelDefinition)
    case pronunciationHelper(character: String, levelDefinition: LevelDefinition)
    
    // Level 2 Screens
    case syllableActivity(levelDefinition: LevelDefinition)
}
