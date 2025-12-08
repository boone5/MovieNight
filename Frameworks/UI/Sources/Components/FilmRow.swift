//
//  MockCustomModals2.swift
//  MovieNight
//
//  Created by Boone on 7/16/24.
//

import Models
import SwiftUI
import SwiftUITrackableScrollView

public struct FilmRow: View {
    public var items: [DetailViewRepresentable]

    @Binding public var selectedFilm: SelectedFilm?

    private let namespace: Namespace.ID
    private let thumbnailWidth: CGFloat
    private let thumbnailHeight: CGFloat

    public init(
        items: [DetailViewRepresentable],
        selectedFilm: Binding<SelectedFilm?>,
        namespace: Namespace.ID,
        thumbnailWidth: CGFloat = 175,
        thumbnailHeight: CGFloat = 250
    ) {
        self.items = items
        self._selectedFilm = selectedFilm
        self.namespace = namespace
        self.thumbnailWidth = thumbnailWidth
        self.thumbnailHeight = thumbnailHeight
    }

    public var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 15) {
                ForEach(items, id: \.id) { film in
                    ThumbnailView(
                        filmID: film.id,
                        posterPath: film.posterPath,
                        width: thumbnailWidth,
                        height: thumbnailHeight,
                        namespace: namespace,
                        isHighlighted: selectedFilm?.id == film.id
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedFilm = SelectedFilm(film: film)
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
        }
        .padding(.horizontal, -15)
        .toolbar(selectedFilm != nil ? .hidden : .visible, for: .tabBar)
    }
}
