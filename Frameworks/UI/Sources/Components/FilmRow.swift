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

    @Binding public var selectedItem: TransitionableMedia?

    private let namespace: Namespace.ID
    private let thumbnailSize: CGSize
    private let sectionTitle: String

    public init(
        sectionTitle: String,
        items: [MediaItem],
        selectedItem: Binding<TransitionableMedia?>,
        namespace: Namespace.ID,
        thumbnailSize: CGSize = CGSize(width: 175, height: 263)
    ) {
        self.sectionTitle = sectionTitle
        self.items = items
        self._selectedItem = selectedItem
        self.namespace = namespace
        self.thumbnailSize = thumbnailSize
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: PLayout.sectionPadding) {
            Text(sectionTitle)
                .font(.montserrat(size: 18, weight: .semibold))

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(items, id: \.id) { film in
                        let sourceID = "\(sectionTitle)-\(film.id)"
                        ThumbnailView(
                            media: film,
                            size: thumbnailSize,
                            transitionConfig: .init(namespace: namespace, id: sourceID)
                        )
                        .onTapGesture {
                            selectedItem = TransitionableMedia(item: film, id: sourceID)
                        }
                    }
                }
                .padding(.horizontal, PLayout.horizontalMarginPadding)
            }
            .scrollClipDisabled()
            .padding(.horizontal, -20)
        }
        .toolbar(selectedItem != nil ? .hidden : .visible, for: .tabBar)
    }
}
