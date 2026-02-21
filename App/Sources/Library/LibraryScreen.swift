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
                if !store.shouldShowContent {
                    VStack(alignment: .leading) {
                        NavigationHeader(title: "Library")
                        Spacer()
                        Text("Your recently watched movies, tv shows,\nand collections.")
                            .font(.montserrat(size: 16, weight: .medium))
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    }
                    .padding(.horizontal, PLayout.horizontalMarginPadding)

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

                            if !recentlyWatchedFilms.isEmpty {
                                FilmRow(
                                    sectionTitle: "Recently Watched",
                                    items: recentlyWatchedFilms.map(MediaItem.init),
                                    selectedItem: $store.selectedItem,
                                    namespace: namespace
                                )
                            }

                            // TODO: In Progress TV Shows
                            InProgressView()

                            CollectionsView(store: store)
                        }
                        .padding(.horizontal, PLayout.horizontalMarginPadding)
                        .padding(.bottom, PLayout.bottomMarginPadding)
                    }
                }
            }
            .task(id: Array(collections)) {
                send(.collectionsUpdated(Array(collections)))
            }
            .task(id: recentlyWatchedFilms.count) {
                send(.recentlyWatchedCountChanged(recentlyWatchedFilms.count))
                send(.collectionsUpdated(Array(collections)))
            }
            .fullScreenCover(item: $store.selectedItem) { selectedFilm in
                MediaDetailView(
                    media: selectedFilm.item,
                    navigationTransitionConfig: .init(namespace: namespace, source: selectedFilm)
                )
            }
            .sheet(item: $store.scope(state: \.addCollection, action: \.addCollection)) { store in
                CreateCollectionSheet(store: store)
            }
        } destination: { store in
            switch store.case {
            case .collectionDetail(let store):
                CollectionDetailView(store: store)
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
