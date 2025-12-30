//
//  CollectionsView.swift
//  App
//
//  Created by Boone on 12/19/25.
//

import Dependencies
import Models
import Networking
import SwiftUI
import UI

struct CollectionsView: View {
    let collections: [FilmCollection]
    let onTapCollection: (FilmCollection) -> Void

    private var visibleCollections: [FilmCollection] {
        collections.filter { $0.id != FilmCollection.watchLaterID }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LibraryScreen.sectionSpacing) {
            Text("Collections")
                .font(.montserrat(size: 18, weight: .semibold))

            ForEach(visibleCollections.enumerated(), id: \.element.id) { idx, collection in
                VStack(spacing: 10) {
                    Button {
                        onTapCollection(collection)
                    } label: {
                        CollectionTypeRow(collection: collection)
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

    struct CollectionTypeRow: View {
        let collection: FilmCollection

        var body: some View {
            HStack(spacing: 15) {
                // TODO: Pass in poster paths of collection
                PosterFanView(items: ["1", "2", "3"])

                VStack(alignment: .leading, spacing: 5) {
                    Text(collection.title ?? "-")
                        .font(.openSans(size: 16, weight: .medium))

                    Text(String(collection.films?.count ?? 0) + " films")
                        .font(.openSans(size: 16))
                        .foregroundStyle(.gray)
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
    @Previewable @Dependency(\.movieProvider) var movieProvider

    let collections: [FilmCollection] = {
        let context = movieProvider.container.viewContext

        let customCollection = FilmCollection(context: context)
        customCollection.id = UUID()
        customCollection.title = "My Favorites"
        customCollection.dateCreated = Date()
        customCollection.type = .custom

        let rankedCollection = FilmCollection(context: context)
        rankedCollection.id = UUID()
        rankedCollection.title = "Top 10 of 2024"
        rankedCollection.dateCreated = Date()
        rankedCollection.type = .ranked

        let smartCollection = FilmCollection(context: context)
        smartCollection.id = UUID()
        smartCollection.title = "Unwatched Sci-Fi"
        smartCollection.dateCreated = Date()
        smartCollection.type = .smart

        return [customCollection, rankedCollection, smartCollection]
    }()

    CollectionsView(
        collections: collections,
        onTapCollection: { _ in }
    )
    .padding()
}

