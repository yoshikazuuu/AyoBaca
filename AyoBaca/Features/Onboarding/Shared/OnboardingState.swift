//
//  OnboardingState.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 04/04/25.
//


// OnboardingState.swift
import SwiftUI
import Combine

class OnboardingState: ObservableObject {
    @Published var childName: String = ""
    @Published var childAge: Int? = nil
    
    // Animation states
    @Published var animateContent: Bool = false
    @Published var animateMascot: Bool = false
}
