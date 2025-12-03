//
//  WatchListRow.swift
//  MovieNight
//
//  Created by Boone on 7/12/25.
//

import SwiftUI

struct WatchList: View {
    @StateObject private var thumbnailViewModel = ThumbnailView.ViewModel()
    
    let watchList: [Film]
    let namespace: Namespace.ID

    @Binding var isExpanded: Bool
    @Binding var selectedFilm: SelectedFilm?

    let gridItems: [GridItem] = [
        GridItem(.flexible(), spacing: 20, alignment: .center),
        GridItem(.flexible(), spacing: 20, alignment: .center)
    ]

    init(
        watchList: [Film],
        namespace: Namespace.ID,
        isExpanded: Binding<Bool>,
        selectedFilm: Binding<SelectedFilm?>
    ) {
        self.watchList = watchList
        self.namespace = namespace
        _isExpanded = isExpanded
        _selectedFilm = selectedFilm
    }

    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 20) {
            ForEach(Array(watchList.enumerated()), id: \.element.id) { index, film in
                Group {
                    if selectedFilm?.id == film.id, isExpanded {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.gray)
                            .frame(width: 150, height: 200)
                            .shadow(radius: 3, y: 4)

                    } else {
                        ThumbnailView(
                            viewModel: thumbnailViewModel,
                            filmID: film.id,
                            posterPath: film.posterPath,
                            width: 175,
                            height: 225,
                            namespace: namespace
                        )
                    }
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        isExpanded = true
                        selectedFilm = SelectedFilm(id: film.id, film: film, posterImage: thumbnailViewModel.posterImage(for: film.posterPath))
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isExpanded = false
    @Previewable @State var selectedFilm: SelectedFilm? = nil
    @Previewable @Namespace var namespace

    WatchList(watchList: [], namespace: namespace, isExpanded: $isExpanded, selectedFilm: $selectedFilm)
}
