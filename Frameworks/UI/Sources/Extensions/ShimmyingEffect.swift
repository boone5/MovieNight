//
//  ShimmyingEffect.swift
//  Frameworks
//
//  Created by Ayren King on 12/12/25.
//

import SwiftUI

extension View {
    /// Adds a shimmying effect to the view.
    public func shimmyingEffect() -> some View {
        self.modifier(ShimmyingEffect())
    }
}

/// A view modifier that adds a shimmying effect to a view.
public struct ShimmyingEffect: ViewModifier {
    /// The current rotation angle for the shimmy effect.
    @State private var rotation: Double = 0

    public func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            .onAppear {
                let shimmyAnimation = Animation
                    .bouncy(duration: 1.2, extraBounce: 0.4)
                    .repeatCount(2)

                withAnimation(shimmyAnimation) {
                    rotation = 7
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(shimmyAnimation) {
                            rotation = 0
                        }
                    }
                }
            }
    }
}
