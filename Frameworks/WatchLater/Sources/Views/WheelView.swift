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

    var circleSize: CGFloat {
        let width = UIScreen.main.bounds.width
        if width > 400 {
            return width * 1.25
        } else {
            return width * 1.05
        }
    }

    @State private var selectedCollection: String? = nil
    @State private var isPresentingCollectionPicker: Bool = false

    @Namespace var transition

    init(items: [MediaItem]) {
        self.items = items
    }

    private var wheelModel: FortuneWheelModel {
        FortuneWheelModel(
            titles: items.compactMap(\.title),
            size: circleSize,
            colors: nil,
            sliceConfig: .init(strokeWidth: 10),
            pointerConfig: .init(pointerColor: .green),
            middleBoltConfig: .init(outerSize: 25, innerSize: 16),
            spinButtonPlacement: .center,
            spinButtonTint: .popRed,
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
        VStack(alignment: .leading, spacing: 0) {
            NavigationHeader(title: "Watch Next")

            Text("Select a collection")
                .font(.openSans(size: 16, weight: .regular))
                .foregroundStyle(.secondary)
                .padding(.top, 5)

            Button {
                isPresentingCollectionPicker = true
            } label: {
                HStack(spacing: 4) {
                    Text(selectedCollection ?? "No collection selected")
                        .font(.openSans(size: 16, weight: .semibold))

                    Image(systemName: "chevron.down")
                }
                .foregroundStyle(.blue)
            }
            .padding(.bottom, 12)

            Spacer()

            FortuneWheel(model: wheelModel)
                .overlay {
                    if items.isEmpty {
                        Circle()
                            .fill(Color.primary.opacity(0.1))
                    }
                }
                .disabled(items.isEmpty)
                .frame(width: UIScreen.main.bounds.width - (PLayout.horizontalMarginPadding * 2))
                .allowsHitTesting(!items.isEmpty)

            Spacer()
        }
        .padding(.horizontal, PLayout.horizontalMarginPadding)
        .safeAreaPadding(.bottom)
        .overlay {
            if let chosenIndex, let item = items[safe: chosenIndex] {
                MediaModal(item: item, chosenIndex: $chosenIndex)
            }
        }
        .animation(.default, value: chosenIndex)
        .sheet(isPresented: $isPresentingCollectionPicker) {
            MediaCollectionPicker(selectedCollection: $selectedCollection)
        }
    }
}

extension Collection {
    /// Returns the element at `index` if it is within bounds, otherwise nil.
    subscript(safe index: Index?) -> Element? {
        guard let index else { return nil }
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var path: NavigationPath = NavigationPath()

    TabView {
        NavigationStack(path: $path) {
            WheelViewPreview()
                // .onAppear { path.append(1) }
                .navigationDestination(for: Int.self ) { _ in
                    WheelViewPreview()
                }
        }
        .tabItem {
            Label("Wheel", systemImage: "circle.grid.3x3.fill")
        }

        Text("Test")
            .tabItem {
                Label("Other", systemImage: "star.fill")
            }
    }
}

struct WheelViewPreview: View {
    init() {
        _ = prepareDependencies {
            $0.imageLoader = .liveValue
        }
    }
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
            .loadCustomFonts()
    }
}

