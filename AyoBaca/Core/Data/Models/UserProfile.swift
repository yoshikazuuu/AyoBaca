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

// Optional: Reading activity model to demonstrate relationships
@Model
final class ReadingActivity {
    var bookTitle: String
    var dateCompleted: Date
    var durationMinutes: Int
    var profile: UserProfile?
    
    init(bookTitle: String, durationMinutes: Int, profile: UserProfile? = nil) {
        self.bookTitle = bookTitle
        self.dateCompleted = Date()
        self.durationMinutes = durationMinutes
        self.profile = profile
    }
}
