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
    let title: String
    let films: [Film]

    @State var selectedFilm: SelectedFilm? = nil
    @Namespace private var namespace

    var body: some View {
        BackgroundColorView {
            ScrollView {
                VStack {
                    WatchList(
                        watchList: films,
                        namespace: namespace,
                        selectedFilm: $selectedFilm
                    )
                }
                .padding(.horizontal, PLayout.horizontalMarginPadding)
                .padding(.bottom, PLayout.bottomMarginPadding)
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // todo
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .fullScreenCover(item: $selectedFilm) { selectedFilm in
            FilmDetailView(
                film: selectedFilm.film,
                navigationTransitionConfig: .init(namespace: namespace, source: selectedFilm.film)
            )
        }
    }
}

#Preview {
    @Previewable @State var selectedFilm: SelectedFilm? = nil
    CollectionDetailView(title: "Some Title", films: [])
}
