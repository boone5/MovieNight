//
//  MockCustomModals2.swift
//  MovieNight
//
//  Created by Boone on 7/16/24.
//

import Models
import SwiftUI

public struct FilmRow: View {
    public var items: [any DetailViewRepresentable]

    @Binding public var selectedFilm: SelectedFilm?

    private let namespace: Namespace.ID
    private let thumbnailSize: CGSize

    public init(
        items: [any DetailViewRepresentable],
        selectedFilm: Binding<SelectedFilm?>,
        namespace: Namespace.ID,
        thumbnailSize: CGSize = CGSize(width: 175, height: 250)
    ) {
        self.items = items
        self._selectedFilm = selectedFilm
        self.namespace = namespace
        self.thumbnailSize = thumbnailSize
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 15) {
                ForEach(items, id: \.id) { film in
                    ThumbnailView(
                        media: film,
                        size: thumbnailSize,
                        transitionConfig: .init(namespace: namespace, source: film)
                    )
                    .onTapGesture {
                        selectedFilm = SelectedFilm(film: film)
                    }
                }
            }
            .padding(.horizontal, PLayout.horizontalMarginPadding)
        }
        .padding(.horizontal, -20)
        .toolbar(selectedFilm != nil ? .hidden : .visible, for: .tabBar)
    }
}
