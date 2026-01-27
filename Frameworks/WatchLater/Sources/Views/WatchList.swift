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

    @Binding var selectedItem: MediaItem?

    let gridItems: [GridItem] = [
        GridItem(.flexible(), spacing: 20, alignment: .center),
        GridItem(.flexible(), spacing: 20, alignment: .center)
    ]

    public init(
        watchList: [MediaItem],
        namespace: Namespace.ID,
        selectedItem: Binding<MediaItem?>
    ) {
        self.watchList = watchList
        self.namespace = namespace
        _selectedItem = selectedItem
    }

    public var body: some View {
        LazyVGrid(columns: gridItems, spacing: 20) {
            ForEach(Array(watchList.enumerated()), id: \.element.id) { index, media in
                ThumbnailView(
                    media: media,
                    size: CGSize(width: 175, height: 263),
                    transitionConfig: .init(namespace: namespace, source: media)
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedItem = media
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedItem: MediaItem? = nil
    @Previewable @Namespace var namespace

    WatchList(watchList: [], namespace: namespace, selectedItem: $selectedItem)
}
