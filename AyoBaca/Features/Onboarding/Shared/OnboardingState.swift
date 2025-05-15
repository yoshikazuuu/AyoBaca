//
//  OnboardingState.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//

import SwiftUI
import Combine

class OnboardingState: ObservableObject {
    @Published var childName: String = ""
    @Published var childAge: Int? = nil

    // Animation states for WelcomeView, can be moved to WelcomeViewModel if not shared
    @Published var animateContent: Bool = false
    @Published var animateMascot: Bool = false
}
