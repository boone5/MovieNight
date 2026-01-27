//
//  MediaModal.swift
//  Frameworks
//
//  Created by Ayren King on 1/27/26.
//

import ConfettiSwiftUI
import Models
import SwiftUI
import UI

struct MediaModal: View {
    let item: MediaItem
    @Binding var chosenIndex: [MediaItem].Index?

    // Needed if we want to transition to the media detail view
    @Namespace var transition

    @State private var isVisible: Bool = false
    @State private var triggerConfetti: Bool = false
    let posterSize: CGSize

    init(item: MediaItem, chosenIndex: Binding<[MediaItem].Index?>) {
        self.item = item
        self._chosenIndex = chosenIndex

        let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.size ?? .zero

        let width = (size.width / 1.5).scaled(by: 0.8)
        let height = width * 1.5 // 2:3 aspect ratio
        self.posterSize = CGSize(width: width, height: height)
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isVisible = false
                        chosenIndex = nil
                    }
                }
                .onAppear {
                    isVisible = true
                    triggerConfetti = true
                }

            VStack {
                if isVisible {
                    ThumbnailView(
                        media: item,
                        size: posterSize,
                        transitionConfig: .init(namespace: transition, source: item)
                    )
                    .shadow(radius: 6, y: 3)
                    .shimmyingEffect()
                    .transition(.scale.combined(with: .opacity) )
                    .padding(.bottom, 16)

                    Text(item.title)
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .transition(.scale.combined(with: .opacity) )

                    HStack(spacing: 20) {
                        Button {
                            // TODO: Definitely remove from watch later list, and update watch history
                            // TODO: Possibly display a detail view here?
                            // or just a small rating modal?
                            // Then dismiss
                        } label: {
                            Text("Watch Now")
                                .font(.openSans(size: 16, weight: .medium))
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Color.popRed, in: .rect(cornerRadius: 15))
                        }
                        .tint(Color.ivoryWhite)

                        Button {
                            withAnimation(.interactiveSpring) {
                                isVisible = false
                                chosenIndex = nil
                            }
                        } label: {
                            Text("Skip")
                                .font(.openSans(size: 16, weight: .medium))
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Color.deepRed, in: .rect(cornerRadius: 15))
                        }
                        .tint(Color.ivoryWhite)
                    }
                    .padding(.horizontal, 24)
                    .transition(.scale.combined(with: .opacity) )
                }
            }
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
            .background {
                if isVisible {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(radius: 10)
                        .transition(.scale.combined(with: .opacity).animation(.bouncy) )
                }
            }
            .padding(.horizontal)
            .overlay(alignment: .centerFirstTextBaseline) {
                Color.clear.frame(height: 1)
                    .confettiCannon(
                        trigger: $triggerConfetti,
                        num: 50,
                        rainHeight: 600,
                        openingAngle: .degrees(45),
                        closingAngle: .degrees(135),
                        hapticFeedback: true
                    )
                    .zIndex(100)
            }
            .confettiCannon(
                trigger: $triggerConfetti,
                num: 100,
                rainHeight: 600,
                openingAngle: .degrees(45),
                closingAngle: .degrees(135),
                hapticFeedback: true
            )
        }
        .animation(.default, value: isVisible)
    }
}
