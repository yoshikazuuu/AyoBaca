//
//  AyoBacaApp.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct AyoBacaApp: App {
    var sharedModelContainer = AppModelContainer.shared

    init() {
        do {
            #if DEBUG
                // try Tips.resetDatastore()
                print("TipKit datastore reset for DEBUG build.")
            #endif
            try Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault),
            ])
            print("TipKit configured successfully.")
        } catch {
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
