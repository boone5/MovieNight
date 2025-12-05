//
//  MockCustomModals2.swift
//  MovieNight
//
//  Created by Boone on 7/16/24.
//

import Networking
import SwiftUI
import SwiftUITrackableScrollView

struct FilmRow: View {
    @StateObject private var viewModel = ThumbnailView.ViewModel()

    public var items: [DetailViewRepresentable]

    @Binding public var isExpanded: Bool
    @Binding public var selectedFilm: SelectedFilm?

    private let namespace: Namespace.ID
    private let thumbnailWidth: CGFloat
    private let thumbnailHeight: CGFloat

    init(
        items: [DetailViewRepresentable],
        isExpanded: Binding<Bool>,
        selectedFilm: Binding<SelectedFilm?>,
        namespace: Namespace.ID,
        thumbnailWidth: CGFloat = 175,
        thumbnailHeight: CGFloat = 250
    ) {
        self.items = items
        self._isExpanded = isExpanded
        self._selectedFilm = selectedFilm
        self.namespace = namespace
        self.thumbnailWidth = thumbnailWidth
        self.thumbnailHeight = thumbnailHeight
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 15) {
                ForEach(items, id: \.id) { film in
                    if selectedFilm?.id == film.id, isExpanded {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.clear)
                            .frame(width: thumbnailWidth, height: thumbnailHeight)
                    } else {
                        ThumbnailView(
                            viewModel: viewModel,
                            filmID: film.id,
                            posterPath: film.posterPath,
                            width: thumbnailWidth,
                            height: thumbnailHeight,
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
            .padding(.horizontal, 15)
        }
        .padding(.horizontal, -15)
        .toolbar(isExpanded ? .hidden : .visible, for: .tabBar)
    }
}
