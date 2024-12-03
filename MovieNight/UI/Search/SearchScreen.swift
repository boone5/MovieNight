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
    case searching
    case results
}

struct SelectedFilm {
    var id: Int64
    var type: ResponseType
}

struct SearchScreen: View {
    @StateObject private var viewModel = SearchViewModel()
    private var movieDataStore: MovieDataStore

    @State private var path: NavigationPath = NavigationPath()
    @State private var searchText: String = ""
    @State private var searchState: SearchState = .explore

    @State private var isFetching: Bool = true

    // detail view
    @State private var trendingMovies: [ResponseType] = []
    @State private var trendingTVShows: [ResponseType] = []

    @State var isExpanded: Bool = false
    @State var selectedFilm: SelectedFilm?

    @Namespace private var namespace

    init(movieDataStore: MovieDataStore) {
        self.movieDataStore = movieDataStore
    }

    var body: some View {
        NavigationStack(path: $path) {
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
                            .foregroundStyle(.white)
                            .font(.system(size: 42, weight: .bold))
                            .padding([.leading, .trailing], 15)

                        CustomSearchBar(vm: viewModel, searchText: $searchText, searchState: $searchState)
                        // no way to adjust default padding from UISearchBar https://stackoverflow.com/questions/55636460/remove-padding-around-uisearchbar-textfield
                            .padding(.horizontal, -8)
                            .padding([.leading, .trailing], 15)

                        if !viewModel.results.isEmpty {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(1..<5) { _ in
                                        Text("TV Shows")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.white)
                                            .padding(10) // Adjust the overall padding as needed
                                            .background(Capsule().foregroundColor(Color("BrightRed")))
                                    }
                                }
                            }
                            .safeAreaInset(edge: .leading, spacing: 0) {
                                VStack(spacing: 0) { }.padding(.leading, 15)
                            }
                            .safeAreaInset(edge: .trailing, spacing: 0) {
                                VStack(spacing: 0) { }.padding(.trailing, 15)
                            }
                            .padding(.bottom, 10)
                        }
                    }

                    Spacer()

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
                            async let shows = await viewModel.getTrendingTVShows()

                            self.trendingMovies = await movies
                            self.trendingTVShows = await shows

                            self.isFetching = false
                        }

                    case .searching:
                        EmptyView()
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
                        List {
                            ForEach(viewModel.results) { detail in
                                Group {
                                    HStack {
//                                        if case let .movie(movie) = detail {
//                                            NavigationLink {
//                                                MovieDetailScreen(id: movie.id, posterPath: movie.posterPath)
//                                            } label: {
//                                                MovieRowView(movie: movie)
//                                            }
//                                        }

//                                        if case let .tvShow(tvShow) = detail {
//                                            NavigationLink {
//                                                TVShowDetailScreen(id: tvShow.id, posterPath: tvShow.posterPath)
//                                            } label: {
//                                                TVShowRowView(tvShow: tvShow)
//                                            }
//                                        }

                                        if case let .people(person) = detail {
                                            Text("Person")
                                                .foregroundStyle(.white)
                                        }

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)

                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .listRowBackground(Color.clear)
                                .buttonStyle(PlainButtonStyle())
                            }

                            // Make this a "couldn't find what you were looking for?" button to submit feedback
                            Text("End of List")
                                .foregroundStyle(.white)
                                .listRowBackground(Color.clear)
                                .task {
                                    await viewModel.loadMore()
                                }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .opacity(isExpanded ? 0 : 1)
                .overlay {
                    if let selectedFilm, isExpanded {
                        FilmDetailView(
                            movieDataStore: movieDataStore,
                            film: selectedFilm.type,
                            namespace: namespace,
                            isExpanded: $isExpanded
                        )
                        .transition(.asymmetric(insertion: .identity, removal: .opacity))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

//struct TVShowRowView: View {
//    let tvShow: TVShowResponse
//
//    var body: some View {
//        ThumbnailView(url: tvShow.posterPath, id: tvShow.id, width: 100, height: 150)
//
//        VStack(alignment: .leading, spacing: 5) {
//            Text(tvShow.title)
//                .font(.title2)
//                .fontWeight(.medium)
//                .lineLimit(2)
//                .foregroundStyle(Color(uiColor: .white))
//                .padding(.leading, 15)
//
//            Text(tvShow.firstAirDate)
//                .font(.caption)
//                .fontWeight(.regular)
//                .foregroundStyle(Color(uiColor: .systemGray))
//                .padding(.leading, 15)
//
//            Text(tvShow.mediaType)
//                .font(.caption)
//                .fontWeight(.regular)
//                .foregroundStyle(Color(uiColor: .systemGray))
//                .padding(.leading, 15)
//        }
//    }
//}

//struct MovieRowView: View {
//    let movie: MovieResponse
//
//    var body: some View {
//        ThumbnailView(url: movie.posterPath, width: 100, height: 150)
//
//        VStack(alignment: .leading, spacing: 5) {
//            Text(movie.title)
//                .font(.title2)
//                .fontWeight(.medium)
//                .lineLimit(2)
//                .foregroundStyle(Color(uiColor: .white))
//                .padding(.leading, 15)
//
//            Text(movie.releaseDate)
//                .font(.caption)
//                .fontWeight(.regular)
//                .foregroundStyle(Color(uiColor: .systemGray))
//                .padding(.leading, 15)
//
//            Text(movie.mediaType)
//                .font(.caption)
//                .fontWeight(.regular)
//                .foregroundStyle(Color(uiColor: .systemGray))
//                .padding(.leading, 15)
//        }
//    }
//}

//#Preview {
//    Search()
//}
