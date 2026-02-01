//
//  PosterFanView.swift
//  UI
//
//  Created by Boone on 12/10/25.
//

import SwiftUI

public struct PosterFanView: View {
    let posterPaths: [String?]
    @State private var currentIndex = 0
    @GestureState private var dragOffset: CGSize = .zero

    private let cardWidth: CGFloat = 60
    private let cardHeight: CGFloat = 90
    private let cardSpacing: CGFloat = 10
    private let maxVisibleCards = 3
    private let rotationAngle: Double = 8
    private let defaultColors: [Color] = [.goldPopcorn, .ivoryWhite, .popRed]
    private let shape = RoundedRectangle(cornerRadius: 8)

    private let cardAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.8)
    private let dragAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.8)

    public init(posterPaths: [String?]) {
        self.posterPaths = posterPaths
    }

    public var body: some View {
        ZStack {
            ForEach(0..<maxVisibleCards, id: \.self) { index in
                cardView(for: index)
                    .frame(width: cardWidth, height: cardHeight)
                    .shadow(
                        color: .black.opacity(index == currentIndex ? 0.3 : 0.15),
                        radius: index == currentIndex ? 15 : 8,
                        x: 0,
                        y: index == currentIndex ? 8 : 4
                    )
                    .opacity(opacity(for: index))
                    .scaleEffect(scale(for: index))
                    .rotationEffect(.degrees(rotation(for: index)))
                    .offset(x: offset(for: index))
                    .zIndex(zIndex(for: index))
                    .animation(cardAnimation, value: currentIndex)
                    .animation(dragAnimation, value: dragOffset)
            }
        }
        .gesture(dragGesture)
    }

    @ViewBuilder
    private func cardView(for index: Int) -> some View {
        if let posterPath = posterPaths[safe: index] {
            CachedAsyncImage(posterPath) { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(shape)
            } placeholder: {
                shape.fill(Color.gray.opacity(0.3))
            }
        } else {
            shape.fill(defaultColors[safe: index] ?? .gray)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                let threshold: CGFloat = 50
                withAnimation(cardAnimation) {
                    if value.translation.width > threshold {
                        currentIndex = max(0, currentIndex - 1)
                    } else if value.translation.width < -threshold {
                        currentIndex = min(maxVisibleCards - 1, currentIndex + 1)
                    }
                }
            }
    }

    private func opacity(for index: Int) -> Double {
        let distance = abs(index - currentIndex)
        return distance == 0 ? 1.0 : max(0.7, 1.0 - Double(distance) * 0.1)
    }

    private func offset(for index: Int) -> CGFloat {
        let relativeIndex = index - currentIndex
        switch relativeIndex {
        case 0:
            return dragOffset.width
        case ..<0:
            return -cardSpacing * CGFloat(min(abs(relativeIndex), 3))
        default:
            return cardSpacing * CGFloat(min(relativeIndex, 3))
        }
    }

    private func rotation(for index: Int) -> Double {
        let relativeIndex = index - currentIndex
        switch relativeIndex {
        case 0:
            return dragOffset.width / 30.0
        case ..<0:
            return -rotationAngle * Double(min(abs(relativeIndex), 3)) / 3.0
        default:
            return rotationAngle * Double(min(relativeIndex, 3)) / 3.0
        }
    }

    private func scale(for index: Int) -> CGFloat {
        let distance = abs(index - currentIndex)
        return distance == 0 ? 1.0 : 1.0 - CGFloat(min(distance, 4)) * 0.05
    }

    private func zIndex(for index: Int) -> Double {
        Double(maxVisibleCards - abs(index - currentIndex))
    }
}
