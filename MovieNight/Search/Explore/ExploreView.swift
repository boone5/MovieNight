//
//  ExploreView.swift
//  MovieNight
//
//  Created by Boone on 7/13/24.
//

import SwiftUI
import SwiftUIIntrospect

struct ExploreView: View {
    @EnvironmentObject var searchViewModel: SearchViewModel

    private var networkManager = NetworkManager()

    @State private var trendingMovies: [ResponseType] = []
    @State private var trendingTVShows: [ResponseType] = []
    @State private var upcoming = [UpcomingResponse.Movie]()

    var namespace: Namespace.ID
    var isExpanded: Binding<Bool>
    var selectedFilm: Binding<SelectedFilm?>

    init(
        namespace: Namespace.ID,
        isExpanded: Binding<Bool>,
        selectedFilm: Binding<SelectedFilm?>
    ) {
        self.namespace = namespace
        self.isExpanded = isExpanded
        self.selectedFilm = selectedFilm
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Popular Movies")
                    .font(.system(size: 18, weight: .bold))
                    .padding([.leading, .trailing, .bottom], 15)

                FilmRow(
                    items: trendingMovies,
                    isExpanded: isExpanded,
                    selectedFilm: selectedFilm,
                    namespace: namespace
                )

                Text("Popular TV Shows")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 30)
                    .padding([.leading, .trailing, .bottom], 15)

                FilmRow(
                    items: trendingTVShows,
                    isExpanded: isExpanded,
                    selectedFilm: selectedFilm,
                    namespace: namespace
                )

    //            Text("Upcoming")
    //                .font(.system(size: 18, weight: .bold))
    //                .foregroundStyle(.white)
    //                .padding(.top, 20)
    //                .padding(.bottom, 15)
    //                .padding([.leading, .trailing], 15)
    //
    //            FilmRow(
    //                items: upcoming,
    //                isExpanded: isExpanded,
    //                showDetailView: showDetailView,
    //                expandedID: expandedID,
    //                namespace: namespace
    //            )
            }
        }
        .task {
            async let movies = getTrendingMovies()
            async let shows = getTrendingTVShows()
            //            async let upcoming = getNowShowing()

            self.trendingMovies = await movies
            self.trendingTVShows = await shows
            //            self.upcoming = await upcoming
        }
    }

    private func getNowShowing() async -> [UpcomingResponse.Movie] {
        do {
            let response: UpcomingResponse = try await networkManager.request(UpcomingEndpoint())
            return response.results
        } catch {
            print("⛔️ Error fetching now playing: \(error)")
            return []
        }
    }

    public func getTrendingMovies() async -> [ResponseType] {
        do {
            let response: SearchResponse = try await networkManager.request(TrendingEndpoint.movies)
            return response.results
        } catch {
            print("⛔️ Error fetching trending movies: \(error)")
            return []
        }
    }

    public func getTrendingTVShows() async -> [ResponseType] {
        do {
            let response: SearchResponse = try await networkManager.request(TrendingEndpoint.tvShow)

            return response.results
        } catch {
            print("⛔️ Error fetching trending tv shows: \(error)")
            return []
        }
    }
}

//#Preview {
//    ExploreView()
//}
