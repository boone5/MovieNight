//
//  ExploreView.swift
//  MovieNight
//
//  Created by Boone on 7/13/24.
//

import Models
import SwiftUI
import UI

struct ExploreView: View {
    var trendingMovies: [MediaItem] = []
    var trendingTVShows: [MediaItem] = []
    var namespace: Namespace.ID
    var selectedItem: Binding<MediaItem?>

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Popular Movies")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 15)

            FilmRow(
                items: trendingMovies,
                selectedItem: selectedItem,
                namespace: namespace
            )

            Text("Popular TV Shows")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 10)
                .padding(.horizontal, 15)

            FilmRow(
                items: trendingTVShows,
                selectedItem: selectedItem,
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
        .padding(.bottom, 15)
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

// #Preview {
//    ExploreView()
// }
