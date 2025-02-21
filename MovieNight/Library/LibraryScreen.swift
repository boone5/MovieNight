//
//  MockLibraryScreen.swift
//  MovieNight
//
//  Created by Boone on 6/30/24.
//

import SwiftUI

struct LibraryScreen: View {
    @StateObject private var thumbnailViewModel = ThumbnailView.ViewModel()

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "dateWatched", ascending: false)])
    var movies: FetchedResults<Film>

    @State private var navigationPath = NavigationPath()
    @State var isExpanded: Bool = false
    @State var selectedFilm: SelectedFilm?
    @Namespace private var namespace

    var body: some View {
        NavigationStack(path: $navigationPath) {
            BackgroundColorView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Library")
                            .font(.system(size: 42, weight: .bold))
                            .padding([.leading, .trailing], 15)
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 20)

                    if movies.isEmpty {
                        Spacer()
                        Text("Start watching films to build your library.")
                            .font(.system(size: 14, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 15)
                        Spacer()

                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Recently watched")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding([.leading, .bottom], 15)

                                FilmRow(
                                    items: Array(movies),
                                    isExpanded: $isExpanded,
                                    selectedFilm: $selectedFilm,
                                    namespace: namespace
                                )

                                WatchLaterView()
                                    .padding(.top, 30)
                                    .padding([.leading, .trailing], 15)

                                CollectionsView()
                                    .padding(.top, 30)
                                    .padding([.leading, .trailing], 15)
                            }
                        }
                    }
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
                .toolbar(isExpanded ? .hidden : .visible, for: .tabBar)
            }
            .navigationDestination(for: FilmCollection.self) { collection in
                let films = collection.films?.array as? [Film] ?? []
                CollectionDetailView(title: collection.title, films: films)
            }
        }
    }
}

//#Preview {
//    MockLibraryScreen()
//}
