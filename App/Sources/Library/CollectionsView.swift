//
//  CollectionsView.swift
//  MovieNight
//
//  Created by Boone on 1/9/25.
//

import Models
import SwiftUI

#Preview {
    CollectionsView()
}

struct CollectionsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateCreated, order: .forward)])
    private var collections: FetchedResults<FilmCollection>

    private var visibleCollections: [FilmCollection] {
        collections.filter { $0.id != FilmCollection.watchLaterID }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Collections")
                .font(.system(size: 18, weight: .bold))

            ForEach(visibleCollections.enumerated(), id: \.element.id) { idx, collection in
                VStack {
                    NavigationLink(value: collection) {
                        HStack(spacing: 15) {
                            // TODO: Pass in poster paths of collection
                            CollectionThumbnailsFan(items: ["1", "2", "3"])

                            VStack(alignment: .leading, spacing: 5) {
                                Text(collection.title ?? "-")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.black)

                                Text(String(collection.films?.count ?? 0) + " films")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.gray)
                            }
                            .padding(.leading, 20)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                                .font(.system(size: 14, weight: .regular))
                        }
                        .padding(.vertical, 10)
                    }

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
