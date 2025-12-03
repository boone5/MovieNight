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

struct MovieActionsView: View {
    let averageColor: UIColor

    var body: some View {
        VStack(spacing: 15) {
            ActionCell {
                Text("Watched with")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white)

            } trailingItem: {
                Image(systemName: "person.crop.circle.badge.plus")
                    .foregroundStyle(.white)
            }

            ActionCell {
                Text("Watch Count")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white)

            } trailingItem: {
                CustomStepper(steps: 100, startStep: 0)
            }
        }
        .roundedBackground(color: Color(uiColor: averageColor))
    }
}

struct ActionView: View {
    let averageColor: UIColor
    let configuration: MediaType

    var body: some View {
        VStack(spacing: 15) {
            switch configuration {
            case .movie:
                CellView(action: .markAsWatched)        // once interacted with, add additional UI to add to a collection
                CellView(action: .addToWatchList)
                CellView(action: .watchedWith)
                CellView(action: .watchCount)

            case .tvShow:
                CellView(action: .markAsWatched)        // once interacted with, add additional UI to add to a collection
                CellView(action: .addToWatchList)
                CellView(action: .watchedWith)
                CellView(action: .watchCount)
                CellView(action: .seasonsWatched)
            }
        }
        .roundedBackground(color: Color(uiColor: averageColor))
    }

    struct CellView: View {
        let action: Action

        var body: some View {
            RoundedRectangle(cornerRadius: 15)
                .frame(height: 50)
                .foregroundStyle(Color(.white).opacity(0.2))
                .shadow(radius: 6, y: 3)
                .overlay {
                    HStack {
                        Text(action.title)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.white)

                        Spacer()

                        if case .watchCount = action {
                            CustomStepper(steps: 2, startStep: 1)
                        } else {
                            Image(systemName: action.imageName)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 15)
                }
        }
    }

    enum Action {
        case watchCount         // specifc to movies
        case watchedWith
        case addToWatchList
        case markAsWatched
        case seasonsWatched     // specific to tv shows

        var imageName: String {
            switch self {
            case .watchCount:
                ""
            case .watchedWith:
                "person.crop.circle.fill.badge.plus"
            case .addToWatchList:
                "rectangle.stack.badge.plus"
            case .markAsWatched:
                "rectangle.badge.plus"
            case .seasonsWatched:
                ""
            }
        }

        var title: String {
            switch self {
            case .watchCount:
                "Watch Count"
            case .watchedWith:
                "Watched With"
            case .addToWatchList:
                "Add to Watch List"
            case .markAsWatched:
                "Mark as Watched"
            case .seasonsWatched:
                "Seasons watched"
            }
        }
    }
}

#Preview {
    ActionView(averageColor: .purple, configuration: .movie)
}

struct CustomStepper: View {
    let steps: Int
    var onIncrement: (() -> Void)? = nil
    var onDecrement: (() -> Void)? = nil

    @State private var currentStep: Int = 0
    @State private var plusButtonPressed: Bool = false
    @State private var minusButtonPressed: Bool = false

    init(steps: Int, startStep: Int, onIncrement: (() -> Void)? = nil, onDecrement: (() -> Void)? = nil) {
        self.steps = steps
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
        self.currentStep = startStep
    }

    var canMinus: Bool {
        currentStep != 0
    }

    var canAdd: Bool {
        currentStep < steps
    }

    var body: some View {
        HStack {
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

            Text(currentStep.description)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)

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
