//
//  HomeScreen.swift
//  MovieNight
//
//  Created by Boone on 11/26/25.
//

import Networking
import SwiftUI

struct HomeScreen: View {
//    @FetchRequest(fetchRequest: Film.recentlyWatched())
//    private var recentlyWatchedFilms: FetchedResults<Film>

    @State private var trendingMovies: [MovieResponse] = []
    @State private var trendingTVShows: [TVShowResponse] = []
    @State private var headerOpacity: Double = 1.0
    @State private var shouldLoad = true

    // Film Detail View Properties
    @State private var isExpanded: Bool = false
    @State private var selectedFilm: SelectedFilm?
    @Namespace private var namespace

    // TODO: Turn into Dependency via environment
    private let networkManager = NetworkManager()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Home")
                        .font(.largeTitle.bold())

                    Spacer()

                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .opacity(headerOpacity)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.frame(in: .scrollView).minY
                } action: { minY in
                    // how many points until fully invisible
                    let fadeThreshold = 50.0
                    headerOpacity = max(0, min(1, (minY + fadeThreshold) / fadeThreshold))
                }
                .padding(.bottom, 5)

                Text("Friends watched")
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

                Text("Trending Movies")
                    .font(.system(size: 18, weight: .bold))

                FilmRow(
                    items: trendingMovies,
                    isExpanded: $isExpanded,
                    selectedFilm: $selectedFilm,
                    namespace: namespace
                )

                Text("Trending TV Shows")
                    .font(.system(size: 18, weight: .bold))

                FilmRow(
                    items: trendingTVShows,
                    isExpanded: $isExpanded,
                    selectedFilm: $selectedFilm,
                    namespace: namespace
                )
            }
            .padding(.horizontal, 15)
        }
        .task {
            guard shouldLoad else { return }

            async let movies = getTrendingMovies()
            async let shows = getTrendingTVShows()
            //            async let upcoming = getNowShowing()

            self.trendingMovies = await movies
            self.trendingTVShows = await shows
            //            self.upcoming = await upcoming

            shouldLoad = false
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

// MARK: Networking

extension HomeScreen {
    public func getTrendingMovies() async -> [MovieResponse] {
        do {
            let response: TrendingMoviesResponse = try await networkManager.request(TMDBEndpoint.trendingMovies)
            return response.results
        } catch {
            print("⛔️ Error fetching trending movies: \(error)")
            return []
        }
    }

    public func getTrendingTVShows() async -> [TVShowResponse] {
        do {
            let response: TrendingTVShowsResponse = try await networkManager.request(TMDBEndpoint.trendingTVShows)
            return response.results
        } catch {
            print("⛔️ Error fetching trending tv shows: \(error)")
            return []
        }
    }
}

#Preview {
    HomeScreen()
}
