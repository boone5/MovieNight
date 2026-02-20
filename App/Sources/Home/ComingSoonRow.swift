//
//  ComingSoonRow.swift
//  App
//
//  Created by Boone on 2/14/26.
//

import Models
import SwiftUI
import UI

struct ComingSoonRow: View {
    var items: [MediaItem]

    @State private var mediaItemToAdd: MediaItem?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 30) {
                ForEach(items, id: \.id) { item in
                    HStack(alignment: .top, spacing: 15) {
                        PosterView(imagePath: item.posterPath, size: CGSize(width: 140, height: 217))

                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(item.title)
                                        .font(.system(size: 16, weight: .semibold))

                                    Text(item.formattedReleaseDate ?? "")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Menu {
                                    Button {
                                        mediaItemToAdd = item
                                    } label: {
                                        Label("Add to Collection", systemImage: "plus")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .labelStyle(.iconOnly)
                                        .frame(width: 35, height: 35)
                                        .glassEffect(.regular.tint(.gray.opacity(0.08)).interactive(), in: .circle)
                                        .clipShape(.circle)
                                }
                                .tint(.primary)
                            }

                            Text(item.overview ?? "")
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(6)
                        }
                        .padding(.vertical, 15)
                    }
                    .containerRelativeFrame(.horizontal, count: 10, span: 9, spacing: 20)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .padding(.horizontal, -PLayout.horizontalMarginPadding)
        .contentMargins(.horizontal, PLayout.horizontalMarginPadding)
    }
}

#Preview {
    ComingSoonRow(items: [])
}
