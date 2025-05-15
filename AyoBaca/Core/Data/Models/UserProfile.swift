//
//  UserProfile.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//


import Foundation
import SwiftData

@Model
final class UserProfile {
    var childName: String
    var childAge: Int
    var lastUpdated: Date
    var completedOnboarding: Bool
    
    init(childName: String, childAge: Int, completedOnboarding: Bool = true) {
        self.childName = childName
        self.childAge = childAge
        self.lastUpdated = Date()
        self.completedOnboarding = completedOnboarding
    }
}
