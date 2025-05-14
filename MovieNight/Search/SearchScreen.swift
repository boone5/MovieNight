//
//  Search.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import SwiftUI
import SwiftUIIntrospect

enum SearchState {
    case explore
    case results
}

struct SelectedFilm {
    var id: Int64
    var film: DetailViewRepresentable
    var posterImage: UIImage?
}

struct SearchScreen: View {
    @StateObject private var viewModel = SearchViewModel()

    // View Properties
    @State private var searchState: SearchState = .explore
    @State private var trendingMovies: [ResponseType] = []
    @State private var trendingTVShows: [ResponseType] = []

    // Expanded View Properties
    @State private var isExpanded: Bool = false
    @State private var selectedFilm: SelectedFilm?
    @Namespace private var namespace

    // Search Bar Properties
    @State private var searchText: String = ""

    var body: some View {
        ZStack {
            Color.clear
                .background {
                    LinearGradient(
                        colors: [Color("BackgroundColor1"), Color("BackgroundColor2")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 7) {
                    Text("Search")
                        .font(.system(size: 42, weight: .bold))
                        .padding([.leading, .trailing], 15)

                    CustomSearchBar(vm: viewModel, searchText: $searchText, searchState: $searchState)
                    // no way to adjust default padding from UISearchBar https://stackoverflow.com/questions/55636460/remove-padding-around-uisearchbar-textfield
                        .padding(.horizontal, -8)
                        .padding([.leading, .trailing], 15)
                }
                .padding(.top, 15)
                .padding(.bottom, 20)

                switch searchState {
                case .explore:
                    ScrollView {
                        ExploreView(
                            trendingMovies: trendingMovies,
                            trendingTVShows: trendingTVShows,
                            namespace: namespace,
                            isExpanded: $isExpanded,
                            selectedFilm: $selectedFilm
                        )
                    }
                    .task {
                        async let movies = viewModel.getTrendingMovies()
                        async let shows = viewModel.getTrendingTVShows()

                        self.trendingMovies = await movies
                        self.trendingTVShows = await shows
                    }

                case .results:
                    // Loading View
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.top, 30)
                    }

                    // Results
                    ListView(
                        results: viewModel.results,
                        namespace: namespace,
                        isExpanded: $isExpanded,
                        selectedFilm: $selectedFilm
                    )
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
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .scrollDismissesKeyboard(.immediately)
        .toolbar(isExpanded ? .hidden : .visible, for: .tabBar)
    }
}

struct ListView: View {
    let results: [DetailViewRepresentable]
    let namespace: Namespace.ID

    @StateObject private var thumbnailViewModel = ThumbnailView.ViewModel()

    @Binding var isExpanded: Bool
    @Binding var selectedFilm: SelectedFilm?

    init(
        results: [DetailViewRepresentable],
        namespace: Namespace.ID,
        isExpanded: Binding<Bool>,
        selectedFilm: Binding<SelectedFilm?>
    ) {
        self.results = results
        self.namespace = namespace
        _isExpanded = isExpanded
        _selectedFilm = selectedFilm
    }

    var body: some View {
        List {
            Group {
                ForEach(results, id: \.id) { film in
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

                // Make this a "couldn't find what you were looking for?" button to submit feedback
                Text("End of List")
                    .foregroundStyle(.white)
                    .listRowBackground(Color.clear)
            }
            .listRowBackground(Color.clear)
            .buttonStyle(PlainButtonStyle())
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

//#Preview {
//    SearchScreen.ListView()
//}
