//
//  ConfettiView.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 05/04/25.
//

import SwiftUI

struct ConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    @State private var confetti: [ConfettiPiece] = []
    
    struct ConfettiPiece: Identifiable {
        let id = UUID()
        let color: Color
        var position: CGPoint
        let rotation: Double
        let scale: CGFloat
        var opacity: Double = 1.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confetti) { piece in
                    Rectangle()
                        .fill(piece.color)
                        .frame(width: 8, height: 8)
                        .position(x: piece.position.x, y: piece.position.y)
                        .rotationEffect(.degrees(piece.rotation))
                        .scaleEffect(piece.scale)
                        .opacity(piece.opacity)
                }
            }
            .onAppear {
                generateConfetti(count: 50, in: geometry.size)
            }
        }
    }
    
    func generateConfetti(count: Int, in size: CGSize) {
        for _ in 0..<count {
            let piece = ConfettiPiece(
                color: colors.randomElement()!,
                position: CGPoint(
                    x: CGFloat.random(in: 50...(size.width - 50)),
                    y: CGFloat.random(in: 50...200)
                ),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.5)
            )
            confetti.append(piece)
        }
        
        // Animate confetti falling and fading
        withAnimation(.linear(duration: 2.0)) {
            for i in 0..<confetti.count {
                let yOffset = CGFloat.random(in: 200...400)
                confetti[i].position.y += yOffset
                confetti[i].opacity = 0
            }
        }
    }
}
