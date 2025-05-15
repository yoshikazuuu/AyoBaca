//
//  DrawingCanvas.swift
//  AyoBaca
//
//  Created by Jerry Febriano on 15/05/25.
//


import SwiftUI

// A reusable canvas view that allows users to draw paths.
// It takes bindings for paths and currentPath, allowing the parent view (WritingView)
// to manage the drawing state.
struct DrawingCanvas: View {
    @Binding var paths: [DrawingPath] // All completed paths
    @Binding var currentPath: DrawingPath // The path currently being drawn

    // Configurable properties for the canvas appearance and drawing tools
    let canvasColor: Color
    let drawingColor: Color // Color for new strokes
    let lineWidth: CGFloat  // Line width for new strokes

    var body: some View {
        Canvas { context, _ in // Size parameter is not used directly here
            // Draw all previously completed paths
            for pathData in paths {
                var path = Path()
                if !pathData.points.isEmpty { // Ensure there are points to draw
                    path.addLines(pathData.points)
                    context.stroke(
                        path,
                        with: .color(pathData.color),
                        style: StrokeStyle(
                            lineWidth: pathData.lineWidth,
                            lineCap: .round, // Smooth line caps
                            lineJoin: .round // Smooth line joins
                        )
                    )
                }
            }

            // Draw the current path being drawn by the user
            var currentDrawingStroke = Path()
            if !currentPath.points.isEmpty {
                currentDrawingStroke.addLines(currentPath.points)
                context.stroke(
                    currentDrawingStroke,
                    with: .color(currentPath.color), // Use current path's color
                    style: StrokeStyle(
                        lineWidth: currentPath.lineWidth, // Use current path's line width
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            }
        }
        .background(canvasColor) // Set the background color of the canvas
        .gesture(
            DragGesture(minimumDistance: 0) // Respond to any drag movement
                .onChanged { value in
                    // If it's the start of a new stroke
                    if currentPath.points.isEmpty {
                        currentPath = DrawingPath(
                            points: [value.location], // Start with the first point
                            color: drawingColor,      // Use the configured drawing color
                            lineWidth: lineWidth        // Use the configured line width
                        )
                    } else {
                        // Append new points to the current path
                        currentPath.points.append(value.location)
                    }
                }
                .onEnded { _ in // value parameter is not used here
                    // When the drag ends, if the current path has points,
                    // add it to the list of completed paths.
                    if !currentPath.points.isEmpty {
                        paths.append(currentPath)
                    }
                    // Reset currentPath to prepare for a new stroke.
                    currentPath = DrawingPath(color: drawingColor, lineWidth: lineWidth)
                }
        )
    }
}