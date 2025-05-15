//
//  ReadingActivity.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//

import Foundation
import SwiftData

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
