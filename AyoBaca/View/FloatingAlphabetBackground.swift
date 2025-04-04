//
//  FloatingAlphabetBackground.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//


import SwiftUI

struct FloatingAlphabetBackground: View {
    // State to trigger and control the animation
    @State private var animate = false
    // Number of letters to display
    let count: Int
    // Font style to use (assuming you have an enum like AppFontType)
    let fontStyle: FontType // e.g., .dylexicRegular, .dylexicBold
    // Optional: Specify allowed characters, defaults to uppercase A-Z
    let characters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<count, id: \.self) { _ in
                    // Generate properties for each letter instance
                    let letter = String(characters.randomElement()!)
                    let size = CGFloat.random(in: 30...80)
                    let initialX = CGFloat.random(in: 0...geometry.size.width)
                    let initialY = CGFloat.random(in: 0...geometry.size.height)
                    let initialRotation = Double.random(in: -45...45)
                    // *** Calculate the static opacity for this letter instance ***
                    let letterOpacity = Double.random(in: 0.05...0.15) // Subtle opacity
                    let duration = Double.random(in: 6...12) // Slower, gentler animation
                    let delay = Double.random(in: 0...5)
                    // Random horizontal and vertical drift amounts
                    let driftX = animate ? CGFloat.random(in: -25...25) : 0
                    let driftY = animate ? CGFloat.random(in: -25...25) : 0
                    // Slight additional rotation during animation
                    let animatedRotation = animate ? Double.random(in: -15...15) : 0
                    
                    Text(letter)
                    // Use your custom font extension here
                        .font(.appFont(fontStyle, size: size))
                    // *** Set the base color to white (or your desired base) ***
                        .foregroundColor(.white)
                    // *** Apply the opacity separately ***
                        .opacity(letterOpacity)
                        .rotationEffect(.degrees(initialRotation + animatedRotation))
                        .position(x: initialX, y: initialY)
                        .offset(x: driftX, y: driftY)
                        .animation(
                            Animation.easeInOut(duration: duration)
                                .repeatForever(autoreverses: true)
                                .delay(delay),
                            value: animate // Animate when the 'animate' state changes
                        )
                }
            }
            // Ensure the ZStack fills the geometry reader space
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped() // Prevent letters from drifting outside the bounds visually
        }
        .onAppear {
            // Start the animation shortly after the view appears
            // Using a slight delay can sometimes help ensure geometry is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // No need for withAnimation here if the animation modifier handles it
                animate = true
            }
        }
        // Important: Ignore safe area if you want it to go edge-to-edge
        .ignoresSafeArea()
        // Allow taps to pass through to views underneath
        .allowsHitTesting(false)
    }
}

// Example Usage Preview (assuming AppFontType exists)
#Preview {
    ZStack {
        // Example gradient background to see the letters
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        // Add the floating alphabet background
        FloatingAlphabetBackground(count: 25, fontStyle: .dylexicRegular) // Use your actual font style
        
        // Add some foreground content to test interaction
        VStack {
            Text("Foreground Content")
                .font(.largeTitle)
                .foregroundColor(.white)
            Button("Test Button") {
                print("Button Tapped")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
