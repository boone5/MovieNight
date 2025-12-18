//
//  CollectionDetailView.swift
//  MovieNight
//
//  Created by Boone on 2/18/25.
//

import ComposableArchitecture
import Models
import SwiftUI
import UI
import WatchLater

@ViewAction(for: CollectionDetailFeature.self)
struct CollectionDetailView: View {
    @Bindable var store: StoreOf<CollectionDetailFeature>

    @Namespace private var namespace

    var body: some View {
        BackgroundColorView {
            ScrollView {
                VStack {
                    WatchList(
                        watchList: store.films,
                        namespace: namespace,
                        selectedFilm: $store.selectedFilm
                    )
                }
                .padding(.horizontal, PLayout.horizontalMarginPadding)
                .padding(.bottom, PLayout.bottomMarginPadding)
            }
        }
        .navigationTitle(store.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        send(.tappedRenameCollection)
                    } label: {
                        Label("Rename Collection", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        send(.tappedDeleteCollection)
                    } label: {
                        Label("Delete Collection", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .fullScreenCover(item: $store.selectedFilm) { selectedFilm in
            FilmDetailView(
                film: selectedFilm.film,
                navigationTransitionConfig: .init(namespace: namespace, source: selectedFilm.film)
            )
        }
    }
}

#Preview {
    CollectionDetailView(
        store: Store(
            initialState: CollectionDetailFeature.State(
                collectionID: UUID(),
                title: "Some Title",
                films: []
            )
        ) {
            CollectionDetailFeature()
        }
    )
}
