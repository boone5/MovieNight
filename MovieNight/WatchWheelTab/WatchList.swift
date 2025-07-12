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
        LazyVStack(spacing: 15) {
            ForEach(Array(watchList), id: \.id) { film in
                HStack(spacing: 0) {
                    if selectedFilm?.id == film.id, isExpanded {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.gray)
                            .frame(width: 80, height: 120)
                            .shadow(radius: 3, y: 4)

                    } else {
                        ThumbnailView(
                            viewModel: thumbnailViewModel,
                            filmID: film.id,
                            posterPath: film.posterPath,
                            width: 80,
                            height: 120,
                            namespace: namespace
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isExpanded = true
                                selectedFilm = SelectedFilm(id: film.id, film: film, posterImage: thumbnailViewModel.posterImage(for: film.posterPath))
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(film.title ?? "")
                            .font(.system(size: 16, weight: .medium))

                        Text(film.mediaType.title)
                            .font(.system(size: 14, weight: .regular))
                    }
                    .padding(.leading, 20)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
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
