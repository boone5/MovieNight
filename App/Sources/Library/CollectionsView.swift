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

            ForEach(visibleCollections, id: \.self) { collection in
                VStack {
                    NavigationLink(value: collection) {
                        HStack(spacing: 15) {
                            Label {
                                Text(collection.title ?? "-")
                                    .font(.system(size: 18, weight: .regular))
                            } icon: {
                                Image(systemName: collection.imageName ?? "smiley")
                                    .font(.system(size: 18, weight: .regular))
                            }

                            Spacer()

                            Text(String(collection.films?.count ?? 0))
                                .font(.system(size: 18, weight: .regular))

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                                .font(.system(size: 14, weight: .regular))
                        }
                        .padding(.vertical, 20)
                    }

                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.3))
                        .frame(height: 1)
                }
            }
        }
    }
}
