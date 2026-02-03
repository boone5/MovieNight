//
//  CollectionsView.swift
//  App
//
//  Created by Boone on 12/19/25.
//

import ComposableArchitecture
import Dependencies
import Models
import Networking
import SwiftUI
import UI

@ViewAction(for: LibraryFeature.self)
struct CollectionsView: View {
    @Bindable var store: StoreOf<LibraryFeature>

    private var visibleCollections: [CollectionModel] {
        store.collections
            .sorted { lhs, rhs in
                // Recently Watched (movieID) always appears first
                if lhs.id == FilmCollection.recentlyWatchedID { return true }
                if rhs.id == FilmCollection.recentlyWatchedID { return false }
                return lhs.dateCreated < rhs.dateCreated
            }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LibraryScreen.sectionSpacing) {
            Text("Collections")
                .font(.montserrat(size: 18, weight: .semibold))

            ForEach(visibleCollections.enumerated(), id: \.element.id) { idx, collection in
                VStack(spacing: 10) {
                    Button {
                        send(.tappedCollection(collection))
                    } label: {
                        Row(collection: collection)
                    }
                    .buttonStyle(.plain)

                    if idx != visibleCollections.endIndex-1 {
                        Rectangle()
                            .foregroundStyle(.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                }
            }
        }
    }
}

// MARK: Row

extension CollectionsView {
    struct Row: View {
        let collection: CollectionModel

        var body: some View {
            HStack(spacing: 15) {
                PosterFanView(posterPaths: collection.posterPaths, collectionType: collection.type)

                VStack(alignment: .leading, spacing: 5) {
                    Text(collection.title)
                        .font(.openSans(size: 16, weight: .medium))

                    HStack(spacing: 0) {
                        Group {
                            Text(collection.type.title)
                            Text(" • ")
                            Text(String(collection.filmCount) + " films")
                        }
                        .font(.openSans(size: 14))
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.leading, 20)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
                    .font(.system(size: 14, weight: .regular))
            }
        }
    }
}

#Preview {
    let collections: [CollectionModel] = [
        CollectionModel(
            id: UUID(),
            title: "My Favorites",
            type: .custom,
            dateCreated: Date(),
            filmCount: 5
        ),
        CollectionModel(
            id: UUID(),
            title: "Top 10 of 2024",
            type: .ranked,
            dateCreated: Date(),
            filmCount: 10
        ),
        CollectionModel(
            id: UUID(),
            title: "Unwatched Sci-Fi",
            type: .watchList,
            dateCreated: Date(),
            filmCount: 3
        )
    ]

    CollectionsView(
        store: Store(
            initialState: LibraryFeature.State(collections: collections),
            reducer: { LibraryFeature() }
        )
    )
    .padding()
}
