//
//  MockCustomModals2.swift
//  MovieNight
//
//  Created by Boone on 7/16/24.
//

import Models
import SwiftUI

public struct FilmRow: View {
    public var items: [MediaItem]

    @Binding public var selectedItem: MediaItem?

    private let namespace: Namespace.ID
    private let thumbnailSize: CGSize

    public init(
        items: [MediaItem],
        selectedItem: Binding<MediaItem?>,
        namespace: Namespace.ID,
        thumbnailSize: CGSize = CGSize(width: 175, height: 263)
    ) {
        self.items = items
        self._selectedItem = selectedItem
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
                        selectedItem = film
                    }
                }
            }
            .padding(.horizontal, PLayout.horizontalMarginPadding)
        }
        .padding(.horizontal, -20)
        .toolbar(selectedItem != nil ? .hidden : .visible, for: .tabBar)
    }
}
