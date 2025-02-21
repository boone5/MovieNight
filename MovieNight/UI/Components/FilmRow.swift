//
//  MockCustomModals2.swift
//  MovieNight
//
//  Created by Boone on 7/16/24.
//

import SwiftUI
import SwiftUITrackableScrollView

struct FilmRow: View {
    @StateObject private var viewModel = ThumbnailView.ViewModel()

    public var items: [DetailViewRepresentable]

    @Binding public var isExpanded: Bool
    @Binding public var selectedFilm: SelectedFilm?

    let namespace: Namespace.ID

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(items, id: \.id) { film in
                    if selectedFilm?.id == film.id, isExpanded {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.clear)
                            .frame(width: 175, height: 250)
                    } else {
                        ThumbnailView(
                            viewModel: viewModel,
                            filmID: film.id,
                            posterPath: film.posterPath,
                            width: 175,
                            height: 250,
                            namespace: namespace
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isExpanded = true
                                selectedFilm = SelectedFilm(id: film.id, film: film, posterImage: viewModel.posterImage(for: film.posterPath))
                            }
                        }
                    }
                }
            }
            .padding(15)
        }
        .padding(.vertical, -15)
        .toolbar(isExpanded ? .hidden : .visible, for: .tabBar)
    }
}
