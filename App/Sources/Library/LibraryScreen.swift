//
//  MockLibraryScreen.swift
//  MovieNight
//
//  Created by Boone on 6/30/24.
//

import Models
import SwiftUI
import UI

struct LibraryScreen: View {
    @FetchRequest(fetchRequest: Film.recentlyWatched())
    private var recentlyWatchedFilms: FetchedResults<Film>

    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateCreated, order: .forward)])
    private var collections: FetchedResults<FilmCollection>

    @State private var navigationPath = NavigationPath()
    @State var selectedFilm: SelectedFilm?
    @State private var headerOpacity: Double = 1.0
    @Namespace private var namespace

    static let stackSpacing: CGFloat = 25
    static let sectionSpacing: CGFloat = 15

    var body: some View {
        NavigationStack(path: $navigationPath) {
            BackgroundColorView {
                if recentlyWatchedFilms.isEmpty {
                    VStack {
                        Spacer()
                        Text("Start watching films to build your library.")
                            .font(.system(size: 14, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 15)
                        Spacer()
                    }

                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: Self.stackSpacing) {
                            NavigationHeader(
                                title: "Library",
                                trailingButtons: [
                                    NavigationHeaderButton(systemImage: "magnifyingglass") {
                                        // TODO: Search Library
                                    },
                                    NavigationHeaderButton(systemImage: "plus") {
                                        // TODO: Add a collection
                                    }
                                ]
                            )
                            .opacity(headerOpacity)
                            .onGeometryChange(for: CGFloat.self) { proxy in
                                proxy.frame(in: .scrollView).minY
                            } action: { minY in
                                // how many points until fully invisible
                                let fadeThreshold = 50.0
                                headerOpacity = max(0, min(1, (minY + fadeThreshold) / fadeThreshold))
                            }

                            RecentlyWatchedView(
                                films: Array(recentlyWatchedFilms),
                                selectedFilm: $selectedFilm,
                                namespace: namespace
                            )

                            // TODO: In Progress TV Shows
                            InProgressView()

                            CollectionsView(collections: Array(collections))
                        }
                        .padding(.horizontal, PLayout.horizontalMarginPadding)
                        .padding(.bottom, PLayout.bottomMarginPadding)
                    }
                }
            }
            .navigationDestination(for: FilmCollection.self) { collection in
                let films = collection.films?.array as? [Film] ?? []
                CollectionDetailView(title: collection.title, films: films)
            }
            .fullScreenCover(item: $selectedFilm) { selectedFilm in
                FilmDetailView(
                    film: selectedFilm.film,
                    navigationTransitionConfig: .init(namespace: namespace, source: selectedFilm.film)
                )
            }
        }
    }

    struct RecentlyWatchedView: View {
        let films: [Film]
        @Binding var selectedFilm: SelectedFilm?
        let namespace: Namespace.ID

        var body: some View {
            VStack(alignment: .leading, spacing: LibraryScreen.sectionSpacing) {
                VStack(alignment: .leading) {
                    Text("Recently watched")
                        .font(.system(size: 18, weight: .bold))

                    Text("\(films.count) this week")
                        .foregroundStyle(.gray)
                        .font(.system(size: 16, weight: .medium))
                }

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
                VStack(alignment: .leading) {
                    Text("In Progress")
                        .font(.system(size: 18, weight: .bold))

                    Text("__ shows")
                        .foregroundStyle(.gray)
                        .font(.system(size: 16, weight: .medium))
                }

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

    struct CollectionsView: View {
        let collections: [FilmCollection]

        private var visibleCollections: [FilmCollection] {
            collections.filter { $0.id != FilmCollection.watchLaterID }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: LibraryScreen.sectionSpacing) {
                Text("Collections")
                    .font(.system(size: 18, weight: .bold))

                ForEach(visibleCollections.enumerated(), id: \.element.id) { idx, collection in
                    VStack(spacing: 10) {
                        NavigationLink(value: collection) {
                            HStack(spacing: 15) {
                                // TODO: Pass in poster paths of collection
                                PosterFanView(items: ["1", "2", "3"])

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(collection.title ?? "-")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.black)

                                    Text(String(collection.films?.count ?? 0) + " films")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundStyle(.gray)
                                }
                                .padding(.leading, 20)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 14, weight: .regular))
                            }
                        }

                        if idx != visibleCollections.endIndex-1 {
                            Rectangle()
                                .foregroundStyle(.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LibraryScreen()
}
