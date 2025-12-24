//
//  WatchListRow.swift
//  MovieNight
//
//  Created by Boone on 7/12/25.
//

import Models
import Networking
import SwiftUI
import UI

public struct WatchList: View {
    let watchList: [MediaItem]
    let namespace: Namespace.ID

    @Binding var selectedFilm: MediaItem?

    let gridItems: [GridItem] = [
        GridItem(.flexible(), spacing: 20, alignment: .center),
        GridItem(.flexible(), spacing: 20, alignment: .center)
    ]

    public init(
        watchList: [MediaItem],
        namespace: Namespace.ID,
        selectedFilm: Binding<MediaItem?>
    ) {
        self.watchList = watchList
        self.namespace = namespace
        _selectedFilm = selectedFilm
    }

    public var body: some View {
        LazyVGrid(columns: gridItems, spacing: 20) {
            ForEach(Array(watchList.enumerated()), id: \.element.id) { index, film in
                ThumbnailView(
                    media: film,
                    size: CGSize(width: 175, height: 225),
                    transitionConfig: .init(namespace: namespace, source: film)
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedFilm = film
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedFilm: MediaItem? = nil
    @Previewable @Namespace var namespace

    WatchList(watchList: [], namespace: namespace, selectedFilm: $selectedFilm)
}
