//
//  LevelStatus.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI

// Defines the visual and interactive status for each level on the map.
enum LevelStatus {
    case locked   // Level is not yet accessible.
    case unlocked // Level is accessible but not the current one.
    case current  // The level the user is actively working on or should start next.
}