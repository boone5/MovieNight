//
//  ActionView.swift
//  MovieNight
//
//  Created by Boone on 3/24/25.
//

import SwiftUI

struct ActionCell<Label: View, Trailing: View>: View {
    let label: (() -> Label)
    let trailingItem: (() -> Trailing)

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 15)
                .frame(height: 50)
                .foregroundStyle(Color(.white).opacity(0.2))
                .shadow(radius: 6, y: 3)
                .overlay {
                    HStack {
                        label()
                        Spacer()
                        trailingItem()
                    }
                    .padding(.horizontal, 15)
                }
        }
    }
}

struct CustomStepper: View {
    let steps: Int
    var onIncrement: (() -> Void)? = nil
    var onDecrement: (() -> Void)? = nil

    @Binding var currentStep: Int
    @State private var plusButtonPressed: Bool = false
    @State private var minusButtonPressed: Bool = false

    init(steps: Int, startStep: Binding<Int>, onIncrement: (() -> Void)? = nil, onDecrement: (() -> Void)? = nil) {
        self.steps = steps
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
        self._currentStep = startStep
    }

    var canMinus: Bool {
        currentStep != 0
    }

    var canAdd: Bool {
        currentStep < steps
    }

    var body: some View {
        HStack(spacing: 25) {
            Image(systemName: "minus")
                .foregroundStyle(canMinus ? .white : .gray)
                .scaleEffect(0.8)
                .background {
                    if minusButtonPressed {
                        Color(.white).opacity(0.8)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(width: 30, height: 30)
                    } else {
                        Color(.white).opacity(0.2)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(width: 30, height: 30)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            // Finger is touching the button
                            if !minusButtonPressed {
                                minusButtonPressed = true
                            }
                        }
                        .onEnded { _ in
                            // Finger lifted
                            minusButtonPressed = false

                            if canMinus {
                                currentStep -= 1
                            }

                            onDecrement?()
                        }
                )

            Image(systemName: "plus")
                .foregroundStyle(canAdd ? .white : .gray)
                .scaleEffect(0.8)
                .background {
                    if plusButtonPressed {
                        Color(.white).opacity(0.8)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(width: 30, height: 30)
                    } else {
                        Color(.white).opacity(0.2)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(width: 30, height: 30)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            // Finger is touching the button
                            if !plusButtonPressed {
                                plusButtonPressed = true
                            }
                        }
                        .onEnded { _ in
                            // Finger lifted
                            plusButtonPressed = false

                            if canAdd {
                                currentStep += 1
                            }
                            onIncrement?()
                        }
                )
        }
    }
}

extension View {
    func roundedBackground(
        color: Color,
        opacity: Double = 0.3,
        cornerRadius: CGFloat = 15
    ) -> some View {
        self.modifier(
            AverageColorBackground(
                color: color,
                opacity: opacity,
                cornerRadius: cornerRadius
            )
        )
    }
}

struct AverageColorBackground: ViewModifier {
    var color: Color
    var opacity: Double = 0.3
    var cornerRadius: CGFloat = 15

    func body(content: Content) -> some View {
        content
            .padding(20)
            .background {
                color.opacity(opacity)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
    }
}
