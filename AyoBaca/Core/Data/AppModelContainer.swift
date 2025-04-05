//
//  AppModelContainer.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

import Foundation
import SwiftData

struct AppModelContainer {
    static let shared: ModelContainer = {
        // Define your schema with actual Model classes later
        // Example: let schema = Schema([ChildProfile.self, ReadingProgress.self])
        let schema = Schema([]) // Keep empty for now as in original code
        let modelConfiguration = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(
                for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
