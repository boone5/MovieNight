//
//  FlippablePosterView.swift
//  MovieNight
//
//  Created by Boone on 2/22/25.
//

import SwiftUI

struct FlippablePosterView: View {
    // Track the cumulative rotation for the flip.
    @State private var flipDegrees: Double = 0
    // A state variable for the initial shimmy offset.
    @State private var shimmyRotation: Double = 0

    var body: some View {
        ZStack {
            // Front Face (Blue)
            Rectangle()
                .foregroundStyle(.blue)
                .frame(width: 150, height: 250)
                .cornerRadius(15)
                .shadow(radius: 6, y: 3)
                .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0))
                .opacity(frontVisible ? 1 : 0)

            // Back Face (Red)
            Rectangle()
                .foregroundStyle(.red)
                .frame(width: 150, height: 250)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.6), radius: 8, y: 4)
                // Add 180° to keep the back face oriented correctly.
                .rotation3DEffect(.degrees(flipDegrees + 180), axis: (x: 0, y: 1, z: 0))
                .opacity(frontVisible ? 0 : 1)
        }
        // Apply the shimmy rotation effect.
        .rotation3DEffect(.degrees(shimmyRotation), axis: (x: 0, y: 1, z: 0))
        .onAppear {
            let shimmyAnimation = Animation
                .bouncy(duration: 1, extraBounce: 0.5)
                .repeatCount(2)

            withAnimation(shimmyAnimation) {
                shimmyRotation = 7

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(shimmyAnimation) {
                        shimmyRotation = 0
                    }
                }
            }
        }
//        .gesture(
//            DragGesture(minimumDistance: 30)
//                .onEnded { value in
//                    withAnimation(.bouncy(duration: 1.5)) {
//                        // For a left-to-right swipe, add 180°.
//                        if value.translation.width > 0 {
//                            flipDegrees += 180
//                        } else if value.translation.width < 0 {
//                            // For a right-to-left swipe, subtract 180°.
//                            flipDegrees -= 180
//                        }
//                    }
//                }
//        )
    }

    // Compute the normalized rotation and decide which side is visible.
    var normalizedDegrees: Double {
        let degrees = flipDegrees.truncatingRemainder(dividingBy: 360)
        return degrees < 0 ? degrees + 360 : degrees
    }

    var frontVisible: Bool {
        // The front is visible when normalizedDegrees is between 0°–90° or 270°–360°.
        normalizedDegrees < 90 || normalizedDegrees > 270
    }
}

#Preview {
    FlippablePosterView()
}
