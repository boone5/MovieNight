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

    var trendingMovies: [MovieResponse] = []
    var trendingTVShows: [TVShowResponse] = []
    var namespace: Namespace.ID
    var isExpanded: Binding<Bool>
    var selectedFilm: Binding<SelectedFilm?>

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
            .padding(.bottom, 30)
        }
    }

//    private func getNowShowing() async -> [UpcomingResponse.Movie] {
//        do {
//            let response: UpcomingResponse = try await networkManager.request(UpcomingEndpoint())
//            return response.results
//        } catch {
//            print("⛔️ Error fetching now playing: \(error)")
//            return []
//        }
//    }
}

//#Preview {
//    ExploreView()
//}
