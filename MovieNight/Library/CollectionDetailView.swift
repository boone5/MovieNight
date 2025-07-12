//
//  CollectionDetailView.swift
//  MovieNight
//
//  Created by Boone on 2/18/25.
//

import SwiftUI

struct CollectionDetailView: View {
    let title: String?
    let films: [Film]

    @State var isExpanded: Bool = false
    @State var selectedFilm: SelectedFilm?
    @Namespace private var namespace

    var body: some View {
        BackgroundColorView {
            ScrollView {
                WatchList(
                    watchList: films,
                    namespace: namespace,
                    isExpanded: $isExpanded,
                    selectedFilm: $selectedFilm
                )
                .padding(.horizontal, 15)
            }
            .navigationTitle(title ?? "-")
        }
    }
}
