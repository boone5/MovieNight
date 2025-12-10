//
//  CollectionThumbnailsFan.swift
//  App
//
//  Created by Boone on 12/10/25.
//


import SwiftUI

struct CollectionThumbnailsFan: View {
    let items: [String] // Array of image names or identifiers
    @State private var currentIndex: Int
    @GestureState private var dragOffset: CGSize = .zero

    private let cardWidth: CGFloat = 60
    private let cardHeight: CGFloat = 90
    private let cardSpacing: CGFloat = 10 // How much cards peek from behind
    private let maxVisibleCards: Int = 4
    private let rotationAngle: Double = 8

    init(items: [String]) {
        self.items = items
        self.currentIndex = 0
    }

    var body: some View {
        ZStack {
            ForEach(visibleIndices, id: \.self) { index in
                CardView(
                    item: items[index],
                    index: index,
                    currentIndex: currentIndex,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight
                )
                .scaleEffect(scaleForIndex(index))
                .rotationEffect(.degrees(rotationForIndex(index)))
                .offset(x: offsetForIndex(index))
                .zIndex(zIndexForIndex(index))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: dragOffset)
            }
        }
        .padding(.leading, Double(currentIndex*10)) // adjust leading padding as a user swipes
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width > threshold {
                        // Swipe right - go to previous
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentIndex = max(0, currentIndex - 1)
                        }
                    } else if value.translation.width < -threshold {
                        // Swipe left - go to next
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentIndex = min(items.count - 1, currentIndex + 1)
                        }
                    }
                }
        )
    }

    private var visibleIndices: [Int] {
        let startIndex = max(0, currentIndex - maxVisibleCards)
        let endIndex = min(items.count - 1, currentIndex + maxVisibleCards)
        return Array(startIndex...endIndex)
    }

    private func offsetForIndex(_ index: Int) -> CGFloat {
        let relativeIndex = index - currentIndex

        // Current card is always centered
        if index == currentIndex {
            return dragOffset.width
        }

        // Cards to the left (previously viewed)
        if relativeIndex < 0 {
            let stackPosition = abs(relativeIndex)
            let baseOffset = -cardSpacing * CGFloat(min(stackPosition, 3))
            return baseOffset
        }

        // Cards to the right (upcoming)
        if relativeIndex > 0 {
            let stackPosition = relativeIndex
            let baseOffset = cardSpacing * CGFloat(min(stackPosition, 3))
            return baseOffset
        }

        return 0
    }

    private func rotationForIndex(_ index: Int) -> Double {
        let relativeIndex = index - currentIndex

        // Current card tilts based on drag
        if index == currentIndex {
            let tiltAmount = Double(dragOffset.width) / 300.0
            return tiltAmount * 10
        }

        // Cards to the left rotate counter-clockwise
        if relativeIndex < 0 {
            let stackPosition = min(abs(relativeIndex), 3)
            return -rotationAngle * Double(stackPosition) / 3.0
        }
        // Cards to the right rotate clockwise
        else {
            let stackPosition = min(relativeIndex, 3)
            return rotationAngle * Double(stackPosition) / 3.0
        }
    }

    private func scaleForIndex(_ index: Int) -> CGFloat {
        let relativeIndex = abs(index - currentIndex)

        if relativeIndex == 0 {
            return 1.0
        }

        // Progressive scaling for depth effect
        let scaleReduction = 1.0 - (CGFloat(min(relativeIndex, 4)) * 0.05)
        return scaleReduction
    }

    private func zIndexForIndex(_ index: Int) -> Double {
        // Current card has highest z-index
        if index == currentIndex {
            return Double(items.count)
        }

        // Cards further from current have lower z-index
        return Double(items.count - abs(index - currentIndex))
    }

    struct CardView: View {
        let item: String
        let index: Int
        let currentIndex: Int
        let cardWidth: CGFloat
        let cardHeight: CGFloat

        var body: some View {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hue: Double(index) * 0.1, saturation: 0.8, brightness: 0.9),
                            Color(hue: Double(index) * 0.1, saturation: 0.6, brightness: 0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: cardWidth, height: cardHeight)
                .shadow(
                    color: Color.black.opacity(index == currentIndex ? 0.3 : 0.15),
                    radius: index == currentIndex ? 15 : 8,
                    x: 0,
                    y: index == currentIndex ? 8 : 4
                )
                .opacity(opacityForIndex(index))
        }

        private func opacityForIndex(_ index: Int) -> Double {
            let relativeIndex = abs(index - currentIndex)
            if relativeIndex == 0 {
                return 1.0
            }
            // Slight opacity reduction for stacked cards
            return max(0.7, 1.0 - (Double(relativeIndex) * 0.1))
        }
    }
}
