//
//  AyoBacaApp.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//

import SwiftUI
import SwiftData
import TipKit // <-- Import TipKit

@main
struct AyoBacaApp: App {
    var sharedModelContainer = AppModelContainer.shared

    init() {
        do {
            #if DEBUG
            // Reset the datastore *before* configuring, only in DEBUG builds
            // This makes tips reappear every time you launch during development.
            // try Tips.resetDatastore()
            print("TipKit datastore reset for DEBUG build.")
            #endif

            // Configure TipKit. Add specific options if needed.
            // If you don't need specific options, you can just call:
            // try Tips.configure()
            try Tips.configure([
                // Example options (uncomment if needed):
                 .displayFrequency(.immediate), // Show tips immediately for testing
                 .datastoreLocation(.applicationDefault) // Default location
            ])
            print("TipKit configured successfully.")

        } catch {
            // Handle potential errors during reset or configuration
            print("Error initializing/configuring TipKit: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
