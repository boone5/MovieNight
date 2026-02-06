//
//  ShakeEffect.swift
//  Frameworks
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    private let amount: CGFloat = 10
    private let shakesPerUnit = 3

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

extension View {
    public func shakeEffect(trigger: Int) -> some View {
        self
            .modifier(ShakeEffect(animatableData: CGFloat(trigger)))
            .animation(.default, value: trigger)
    }
}
