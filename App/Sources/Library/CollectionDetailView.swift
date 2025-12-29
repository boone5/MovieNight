//
//  CollectionDetailView.swift
//  MovieNight
//
//  Created by Boone on 2/18/25.
//

import Models
import SwiftUI
import UI
import WatchLater

struct CollectionDetailView: View {
    let title: String?
    let items: [MediaItem]

    @State var selectedItem: MediaItem?
    @Namespace private var namespace

    var body: some View {
        BackgroundColorView {
            ScrollView {
                WatchList(
                    watchList: items,
                    namespace: namespace,
                    selectedItem: $selectedItem
                )
                .padding(.horizontal, 15)
            }
            .navigationTitle(title ?? "-")
        }
    }
}
