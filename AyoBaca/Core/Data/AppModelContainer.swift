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
        let schema = Schema([UserProfile.self, ReadingActivity.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true)

        do {
            return try ModelContainer(
                for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @MainActor
    static func previewContainer() -> ModelContainer {
        let schema = Schema([UserProfile.self, ReadingActivity.self])
        let config = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(
                for: schema, configurations: [config])

            let sampleUser = UserProfile(childName: "Budi", childAge: 7)
            container.mainContext.insert(sampleUser)

            let activity1 = ReadingActivity(
                bookTitle: "Petualangan Alfabet",
                durationMinutes: 15,
                profile: sampleUser)
            let activity2 = ReadingActivity(
                bookTitle: "Si Kancil",
                durationMinutes: 10,
                profile: sampleUser)
            container.mainContext.insert(activity1)
            container.mainContext.insert(activity2)

            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }

    @MainActor
    static var preview: ModelContainer {
        return previewContainer()
    }
}
