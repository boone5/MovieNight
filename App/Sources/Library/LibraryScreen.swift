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

    @FetchRequest(
        entity: Film.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Film.dateWatched, ascending: true)],
        predicate: NSPredicate(format: "collection.id == %@", FilmCollection.watchLaterID as CVarArg)
    )
    private var watchList: FetchedResults<Film>

    @State private var navigationPath = NavigationPath()
    @State var selectedFilm: SelectedFilm?
    @State private var headerOpacity: Double = 1.0
    @Namespace private var namespace

    private let sectionSpacing: CGFloat = 10

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
                        VStack(alignment: .leading, spacing: 15) {
                            // Custom header
                            HStack(spacing: 0) {
                                Text("Library")
                                    .font(.largeTitle.bold())

                                Spacer()

                                Button {
                                    // TODO: Search Library
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                        .padding(5)
                                }
                                .buttonStyle(.glass)
                                .clipShape(Circle())

                                Button {
                                    // TODO: Add a collection
                                } label: {
                                    Image(systemName: "plus")
                                        .padding(5)
                                }
                                .buttonStyle(.glass)
                                .clipShape(Circle())
                            }
                            .opacity(headerOpacity)
                            .onGeometryChange(for: CGFloat.self) { proxy in
                                proxy.frame(in: .scrollView).minY
                            } action: { minY in
                                // how many points until fully invisible
                                let fadeThreshold = 50.0
                                headerOpacity = max(0, min(1, (minY + fadeThreshold) / fadeThreshold))
                            }

                            HStack {
                                Text("Recently watched")
                                    .font(.system(size: 18, weight: .bold))

                                Spacer()

                                Text("\(recentlyWatchedFilms.count) this week")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .padding(.top, sectionSpacing)

                            FilmRow(
                                items: Array(recentlyWatchedFilms),
                                selectedFilm: $selectedFilm,
                                namespace: namespace
                            )

                            // TODO: Support In Progress TV Shows
                            HStack {
                                Text("In Progress")
                                    .font(.system(size: 18, weight: .bold))

                                Spacer()

                                Text("\(recentlyWatchedFilms.count) shows")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .padding(.top, sectionSpacing)

                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(1..<5) { _ in
                                        RoundedRectangle(cornerRadius: 15)
                                            .frame(width: 125, height: 175)
                                    }
                                }
                                .padding(.horizontal, 15)
                            }
                            .padding(.horizontal, -15)

                            CollectionsView()
                                .padding(.top, sectionSpacing)
                        }
                        .padding(.horizontal, 15)
                        .padding(.bottom, 30)
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
}

#Preview {
    LibraryScreen()
}
