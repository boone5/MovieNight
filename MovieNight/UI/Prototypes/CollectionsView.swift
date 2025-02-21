//
//  CollectionsView.swift
//  MovieNight
//
//  Created by Boone on 1/9/25.
//

import SwiftUI

#Preview {
    CollectionsView()
}

struct CollectionsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateCreated, order: .forward)])
    var collections: FetchedResults<FilmCollection>

    var body: some View {
        VStack(alignment: .leading) {
            Text("Collections")
                .foregroundStyle(.white)
                .font(.system(size: 22, weight: .bold))

            ForEach(collections, id: \.self) { collection in
                VStack {
                    NavigationLink(value: collection) {
                        HStack(spacing: 15) {
                            Label {
                                Text(collection.title ?? "-")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18, weight: .regular))
                            } icon: {
                                Image(systemName: collection.imageName ?? "smiley")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18, weight: .regular))
                            }

                            Spacer()

                            Text(String(collection.films?.count ?? 0))
                                .foregroundStyle(.white)
                                .font(.system(size: 18, weight: .regular))

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .regular))
                        }
                        .padding(.vertical, 20)
                    }

                    Rectangle()
                        .foregroundStyle(.white.opacity(0.3))
                        .frame(height: 1)
                }
            }
        }
    }
}
