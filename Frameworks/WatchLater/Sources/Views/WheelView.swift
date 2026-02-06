//
//  WheelView.swift
//  MovieNight
//
//  Created by Boone on 7/12/25.
//

import ComposableArchitecture
import CoreData
import Dependencies
import Models
import Networking
import SwiftUI
import UI

import FortuneWheel

struct WheelView: View {
    @Bindable var store: StoreOf<WatchLaterFeature>
    var collections: FetchedResults<FilmCollection>

    init(store: StoreOf<WatchLaterFeature>, collections: FetchedResults<FilmCollection>) {
        self.store = store
        self.collections = collections
    }

    private let totalSpinDuration: Double = 5.0

    var circleSize: CGFloat {
        guard let width = UIWindow.current?.currentSceneWidth else { return 400 }
        if width > 400 {
            return width * 1.25
        } else {
            return width * 1.05
        }
    }

    @Namespace var transition

    private var wheelModel: FortuneWheelModel {
        FortuneWheelModel(
            titles: store.selectedCollectionMediaItems?.compactMap(\.title) ?? [],
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
                store.send(.view(.wheelStateDidChange($0)), animation: .default)
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
                store.send(.view(.selectCollectionPickerButtonTapped))
            } label: {
                HStack(spacing: 4) {
                    Text(store.selectedCollection?.safeTitle ?? "No collection selected")
                        .font(.openSans(size: 16, weight: .semibold))

                    Image(systemName: "chevron.down")
                }
                .foregroundStyle(.blue)
            }
            .disabled(!store.canUpdateCollection)
            .padding(.bottom, 12)

            Spacer()

            FortuneWheel(model: wheelModel)
                .overlay {
                    if store.selectedCollectionHasItems == false {
                        Circle()
                            .fill(Color.primary.opacity(0.1))
                    }
                }
                .disabled(store.selectedCollectionHasItems == false)
                .frame(width: (UIWindow.current?.currentSceneWidth ?? 400) - (PLayout.horizontalMarginPadding * 2))
                .allowsHitTesting(!(store.selectedCollectionHasItems == false))

            Spacer()
        }
        .padding(.horizontal, PLayout.horizontalMarginPadding)
        .safeAreaPadding(.bottom)
        .overlay {
            if let item = store.selectedCollectionMediaItems?[safe: store.chosenWheelIndex] {
                MediaModal(item: item, onDismiss: { store.send(.view(.onMediaModalDismiss), animation: .interactiveSpring) })
            }
        }
        .animation(.default, value: store.chosenWheelIndex)
        .sheet(isPresented: $store.isPresentingCollectionPicker) {
            MediaCollectionPicker(
                collections: collections,
                selectedCollectionID: store.selectedCollection?.id,
                onCollectionPickerValueUpdated: { selectedId in
                    let collection = collections.first { $0.id == selectedId }
                    store.send(.view(.collectionPickerValueUpdated(collection)))
                }
            )
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
