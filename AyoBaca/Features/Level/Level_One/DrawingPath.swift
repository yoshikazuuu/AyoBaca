//
//  DrawingPath.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 07/04/25.
//


// Features/LearningActivities/Writing/Views/DrawingCanvas.swift

import SwiftUI

struct DrawingPath {
    var points: [CGPoint] = []
    var color: Color = .black // Default color
    var lineWidth: CGFloat = 5.0 // Default width
}

struct DrawingCanvas: View {
    @Binding var paths: [DrawingPath]
    @State private var currentPath = DrawingPath()

    let canvasColor: Color
    let drawingColor: Color
    let lineWidth: CGFloat

    var body: some View {
        Canvas { context, size in
            // Draw completed paths
            for pathData in paths {
                var path = Path()
                path.addLines(pathData.points)
                context.stroke(
                    path,
                    with: .color(pathData.color),
                    lineWidth: pathData.lineWidth)
            }

            // Draw the current path being drawn
            var currentDrawingPath = Path()
            currentDrawingPath.addLines(currentPath.points)
            context.stroke(
                currentDrawingPath,
                with: .color(currentPath.color),
                lineWidth: currentPath.lineWidth)

        }
        .background(canvasColor) // Set canvas background
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    // Start a new path if needed (first point)
                    if currentPath.points.isEmpty {
                        currentPath = DrawingPath(
                            color: drawingColor, lineWidth: lineWidth)
                    }
                    currentPath.points.append(value.location)
                }
                .onEnded { value in
                    // Only add the path if it has points
                    if !currentPath.points.isEmpty {
                        paths.append(currentPath)
                    }
                    // Reset current path for the next stroke
                    currentPath = DrawingPath()
                }
        )
    }
}

// Optional Preview for the Canvas itself
#Preview {
    @Previewable @State var previewPaths: [DrawingPath] = []
    return DrawingCanvas(
        paths: $previewPaths,
        canvasColor: .white,
        drawingColor: .blue,
        lineWidth: 8.0
    )
    .frame(width: 300, height: 300)
    .border(Color.gray)
}
