//
//  HomeScreen.swift
//  MovieNight
//
//  Created by Boone on 11/26/25.
//

import Dependencies
import Models
import Networking
import SwiftUI
import UI

struct HomeScreen: View {
    //    @FetchRequest(fetchRequest: Film.recentlyWatched())
    //    private var recentlyWatchedFilms: FetchedResults<Film>

    @State private var trendingMovies: [MovieResponse] = []
    @State private var trendingTVShows: [TVShowResponse] = []
    @State private var shouldLoad = true

    // Film Detail View Properties
    @State private var selectedFilm: SelectedFilm?

    @Namespace private var namespace

    @Dependency(\.networkClient) var networkClient

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                NavigationHeader(
                    title: "Home",
                    trailingButtons: [
                        NavigationHeaderButton(systemImage: "person") {
                            // TODO: Implement profile button action (e.g., navigate to profile screen).
                        }
                    ]
                )
                .padding(.bottom, 5)

                Text("Friends watched")
                    .font(.montserrat(size: 18, weight: .semibold))

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
                    .font(.montserrat(size: 18, weight: .semibold))

                FilmRow(
                    items: trendingMovies,
                    selectedFilm: $selectedFilm,
                    namespace: namespace
                )

                Text("Trending TV Shows")
                    .font(.montserrat(size: 18, weight: .semibold))

                FilmRow(
                    items: trendingTVShows,
                    selectedFilm: $selectedFilm,
                    namespace: namespace
                )
            }
            .padding(.horizontal, 15)
        }
        .background(Color.background)
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
        .fullScreenCover(item: $selectedFilm) { selectedFilm in
            FilmDetailView(
                film: selectedFilm.film,
                navigationTransitionConfig: .init(namespace: namespace, source: selectedFilm.film)
            )
        }
    }
}

// MARK: Networking

extension HomeScreen {
    public func getTrendingMovies() async -> [MovieResponse] {
        do {
            let response: TrendingMoviesResponse = try await networkClient.request(TMDBEndpoint.trendingMovies)
            return response.results
        } catch {
            print("⛔️ Error fetching trending movies: \(error)")
            return []
        }
    }

    public func getTrendingTVShows() async -> [TVShowResponse] {
        do {
            let response: TrendingTVShowsResponse = try await networkClient.request(TMDBEndpoint.trendingTVShows)
            return response.results
        } catch {
            print("⛔️ Error fetching trending tv shows: \(error)")
            return []
        }
    }
}

#Preview {
    HomeScreen()
        .loadCustomFonts()
}
