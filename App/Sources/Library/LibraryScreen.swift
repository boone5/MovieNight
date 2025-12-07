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
    @StateObject private var thumbnailViewModel = ThumbnailView.ViewModel()

    @FetchRequest(fetchRequest: Film.recentlyWatched())
    private var recentlyWatchedFilms: FetchedResults<Film>

    @FetchRequest(
        entity: Film.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Film.dateWatched, ascending: true)],
        predicate: NSPredicate(format: "collection.id == %@", FilmCollection.watchLaterID as CVarArg)
    )
    private var watchList: FetchedResults<Film>

    @State private var navigationPath = NavigationPath()
    @State var isExpanded: Bool = false
    @State var selectedFilm: SelectedFilm?
    @State private var headerOpacity: Double = 1.0
    @Namespace private var namespace

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
                            Text("Library")
                                .font(.largeTitle.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .opacity(headerOpacity)
                                .onGeometryChange(for: CGFloat.self) { proxy in
                                    proxy.frame(in: .scrollView).minY
                                } action: { minY in
                                    // how many points until fully invisible
                                    let fadeThreshold = 50.0
                                    headerOpacity = max(0, min(1, (minY + fadeThreshold) / fadeThreshold))
                                }
                                .padding(.bottom, 5)

                            Text("Recently watched")
                                .font(.system(size: 18, weight: .bold))

                            FilmRow(
                                items: Array(recentlyWatchedFilms),
                                isExpanded: $isExpanded,
                                selectedFilm: $selectedFilm,
                                namespace: namespace
                            )

                            Text("In Progress")
                                .font(.system(size: 18, weight: .bold))

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
                                .padding(.top, 10)
                        }
                        .padding(.horizontal, 15)
                    }
                }
            }
            .navigationDestination(for: FilmCollection.self) { collection in
                let films = collection.films?.array as? [Film] ?? []
                CollectionDetailView(title: collection.title, films: films)
            }
            .opacity(isExpanded ? 0 : 1)
            .overlay {
                if let selectedFilm, isExpanded {
                    FilmDetailView(
                        film: selectedFilm.film,
                        namespace: namespace,
                        isExpanded: $isExpanded,
                        uiImage: selectedFilm.posterImage
                    )
                    .transition(.asymmetric(insertion: .identity, removal: .opacity))
                }
            }
        }
    }
}

//#Preview {
//    MockLibraryScreen()
//}
