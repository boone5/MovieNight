//
//  LibraryScreen.swift
//  MovieNight
//
//  Created by Boone on 6/30/24.
//

import ComposableArchitecture
import Models
import Networking
import SwiftUI
import UI

@ViewAction(for: LibraryFeature.self)
struct LibraryScreen: View {
    @Bindable public var store: StoreOf<LibraryFeature>

    @FetchRequest(fetchRequest: Film.recentlyWatched())
    private var recentlyWatchedFilms: FetchedResults<Film>

    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateCreated, order: .forward)])
    private var collections: FetchedResults<FilmCollection>

    @Namespace private var namespace

    static let stackSpacing: CGFloat = 25
    static let sectionSpacing: CGFloat = 15

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            BackgroundColorView {
                if recentlyWatchedFilms.isEmpty {
                    VStack {
                        Spacer()
                        Text("Start watching films to build your library.")
                            .font(.system(size: 14, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, PLayout.horizontalMarginPadding)
                        Spacer()
                    }

                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: Self.stackSpacing) {
                            NavigationHeader(
                                title: "Library",
                                trailingButtons: [
                                    NavigationHeaderButton(systemImage: "folder.badge.plus") {
                                        send(.tappedAddCollectionButton)
                                    }
                                ]
                            )

                            RecentlyWatchedView(
                                films: Array(recentlyWatchedFilms),
                                selectedFilm: $store.selectedFilm,
                                namespace: namespace
                            )

                            // TODO: In Progress TV Shows
                            InProgressView()

                            CollectionsView(store: store)
                        }
                        .padding(.horizontal, PLayout.horizontalMarginPadding)
                        .padding(.bottom, PLayout.bottomMarginPadding)
                    }
                    .onAppear {
                        send(.collectionsUpdated(Array(collections)))
                    }
                }
            }
            .fullScreenCover(item: $store.selectedFilm) { selectedFilm in
                FilmDetailView(
                    film: selectedFilm.film,
                    navigationTransitionConfig: .init(namespace: namespace, source: selectedFilm.film)
                )
            }
            .sheet(item: $store.scope(state: \.addCollection, action: \.addCollection)) { store in
                AddCollectionSheet(store: store)
            }
        } destination: { store in
            switch store.case {
            case .collectionDetail(let store):
                CollectionDetailView(store: store)
            }
        }
    }

    struct RecentlyWatchedView: View {
        let films: [Film]
        @Binding var selectedFilm: SelectedFilm?
        let namespace: Namespace.ID

        var body: some View {
            VStack(alignment: .leading, spacing: LibraryScreen.sectionSpacing) {
                Text("Recently watched")
                    .font(.system(size: 18, weight: .bold))

                FilmRow(
                    items: films,
                    selectedFilm: $selectedFilm,
                    namespace: namespace
                )
            }
        }
    }

    struct InProgressView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: LibraryScreen.sectionSpacing) {
                Text("In Progress")
                    .font(.system(size: 18, weight: .bold))

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(1..<5) { _ in
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: 125, height: 175)
                        }
                    }
                    .padding(.horizontal, PLayout.horizontalMarginPadding)
                }
                .padding(.horizontal, -PLayout.horizontalMarginPadding)
            }
        }
    }
}

#Preview {
    LibraryScreen(
        store: Store(initialState: LibraryFeature.State()) {
            LibraryFeature()
        }
    )
}
