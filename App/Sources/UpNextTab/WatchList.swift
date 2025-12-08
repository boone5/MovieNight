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

struct WatchList: View {
    let watchList: [Film]
    let namespace: Namespace.ID

    @Binding var selectedFilm: SelectedFilm?

    let gridItems: [GridItem] = [
        GridItem(.flexible(), spacing: 20, alignment: .center),
        GridItem(.flexible(), spacing: 20, alignment: .center)
    ]

    init(
        watchList: [Film],
        namespace: Namespace.ID,
        selectedFilm: Binding<SelectedFilm?>
    ) {
        self.watchList = watchList
        self.namespace = namespace
        _selectedFilm = selectedFilm
    }

    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 20) {
            ForEach(Array(watchList.enumerated()), id: \.element.id) { index, film in
                ThumbnailView(
                    filmID: film.id,
                    posterPath: film.posterPath,
                    width: 175,
                    height: 225,
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
    }
}

#Preview {
    @Previewable @State var selectedFilm: SelectedFilm? = nil
    @Previewable @Namespace var namespace

    WatchList(watchList: [], namespace: namespace, selectedFilm: $selectedFilm)
}
