//
//  WheelView.swift
//  MovieNight
//
//  Created by Boone on 7/12/25.
//

import CoreData
import Dependencies
import Models
import Networking
import SwiftUI
import UI

import FortuneWheel

struct WheelView: View {
    @State private var chosenIndex: [MediaItem].Index? = nil

    private let totalSpinDuration: Double = 5.0

    private let items: [MediaItem]

    @Namespace var transition

    init(items: [MediaItem]) {
        self.items = items
    }

    private var wheelModel: FortuneWheelModel {
        FortuneWheelModel(
            titles: items.compactMap(\.title),
            size: 350,
            colors: nil,
            sliceConfig: .init(strokeWidth: 10),
            pointerConfig: .init(pointerColor: .green),
            middleBoltConfig: .init(outerSize: 25, innerSize: 16),
            spinButtonPlacement: .bottom,
            spinButtonSpacing: 48,
            animationConfig: .init(duration: totalSpinDuration),
            onSpinStateChange: {
                switch $0 {
                case .idle:
                    print("IDLE")
                case .spinning:
                    withAnimation {
                        chosenIndex = nil
                    }
                case .finished(let index):
                    withAnimation {
                        chosenIndex = index
                    }
                }
            }
        )
    }

    var body: some View {
        BackgroundColorView {
            VStack(spacing: 0) {
                Text("Spin the wheel!")
                    .font(.system(size: 30, weight: .bold))

                Text("Swipe to spin the wheel and let fate decide your next movie night pick.")
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)

                Spacer()

                FortuneWheel(model: wheelModel)

                Spacer()
            }
            .padding(.horizontal, PLayout.horizontalMarginPadding)
        }
        .safeAreaPadding(.bottom)
        .overlay {
            if let chosenIndex, let item = items[safe: chosenIndex] {
                MediaModal(item: item, chosenIndex: $chosenIndex)
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .animation(.default, value: chosenIndex)
    }
}

private struct MediaModal: View {
    let item: MediaItem
    @Binding var chosenIndex: [MediaItem].Index?

    // Needed if we want to transition to the media detail view
    @Namespace var transition

    @State private var isVisible: Bool = false
    let posterSize: CGSize

    init(item: MediaItem, chosenIndex: Binding<[MediaItem].Index?>) {
        self.item = item
        self._chosenIndex = chosenIndex

        let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.size ?? .zero
        self.posterSize = CGSize(width: size.width / 1.5, height: size.height / 2.4)
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
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                        .transition(.scale.combined(with: .opacity) )

                    HStack {
                        Button("Watch", role: .confirm) {
                            // TODO: Definitely remove from watch later list, and update watch history
                            // TODO: Possibly display a detail view here?
                            // or just a small rating modal?
                            // Then dismiss
                        }
                        .buttonBorderShape(.roundedRectangle(radius: 8))
                        .buttonStyle(.glass)

                        Button("Skip", role: .cancel) {
                            withAnimation(.interactiveSpring) {
                                isVisible = false
                                chosenIndex = nil
                            }
                        }
                        .buttonBorderShape(.roundedRectangle(radius: 8))
                        .buttonStyle(.glass)
                    }
                    .transition(.scale.combined(with: .opacity) )
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 32)
            .background {
                if isVisible {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(radius: 10)
                        .transition(.scale.combined(with: .opacity).animation(.bouncy) )
                }
            }
        }
        .animation(.default, value: isVisible)
    }
}

extension Collection {
    /// Returns the element at `index` if it is within bounds, otherwise nil.
    subscript(safe index: Index?) -> Element? {
        guard let index else { return nil }
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    @Previewable @State var path: NavigationPath = NavigationPath()

    TabView {
        NavigationStack(path: $path) {
            WheelViewPreview()
                .onAppear { path.append(1) }
                .navigationDestination(for: Int.self ) { _ in
                    WheelViewPreview()
                }
        }
        .tabItem {
            Label("Wheel", systemImage: "circle.grid.3x3.fill")
        }
    }
}

struct WheelViewPreview: View {
    let films: [MediaItem] = {
        @Dependency(\.movieProvider) var movieProvider
        let context = movieProvider.container.viewContext
        let watchList = FilmCollection(context: context)
        watchList.id = FilmCollection.watchLaterID

        var films: [Film] = []

        for i in 0..<3 {
            let film = Film(context: context)
            film.title = "Mock Film \(i)"
            films.append(film)
        }
        return films.map(MediaItem.init)
    }()

    var body: some View {
        WheelView(items: films)
    }
}
