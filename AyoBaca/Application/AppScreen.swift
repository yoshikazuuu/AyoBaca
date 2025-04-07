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
    case mainApp
    case levelMap
    case profile

    // New Learning Activity Screens
    case characterSelection(levelId: Int) // Pass level ID if needed later
    case spellingActivity(character: String)
    case writingActivity(character: String)
}
