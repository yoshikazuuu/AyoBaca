//
//  AyoBacaApp.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//

import SwiftUI
import SwiftData

@main
struct AyoBacaApp: App {
    var sharedModelContainer = AppModelContainer.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
