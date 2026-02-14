//
//  HomeScreen.swift
//  MovieNight
//
//  Created by Boone on 11/26/25.
//

import ComposableArchitecture
import Models
import Networking
import SwiftUI
import UI

@ViewAction(for: HomeFeature.self)
struct HomeScreen: View {
    @Bindable var store: StoreOf<HomeFeature>

    @Namespace private var namespace

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                NavigationHeader(
                    title: "Discover",
                    trailingButtons: [
                        NavigationHeaderButton(systemImage: "person") {
                            // TODO: Implement profile button action (e.g., navigate to profile screen).
                        }
                    ]
                )
                .padding(.bottom, 5)

                Text("In Theaters Now")
                    .font(.montserrat(size: 18, weight: .semibold))
                    .padding(.top, 10)

                FilmRow(
                    items: store.nowPlaying,
                    selectedItem: $store.selectedItem,
                    namespace: namespace
                )

                Text("Coming Soon")
                    .font(.montserrat(size: 18, weight: .semibold))
                    .padding(.top, 10)

                ComingSoonRow(items: store.upcoming)

                Text("Trending Movies")
                    .font(.montserrat(size: 18, weight: .semibold))
                    .padding(.top, 10)

                FilmRow(
                    items: store.trendingMovies,
                    selectedItem: $store.selectedItem,
                    namespace: namespace
                )

                Text("Trending TV Shows")
                    .font(.montserrat(size: 18, weight: .semibold))
                    .padding(.top, 10)

                FilmRow(
                    items: store.trendingTVShows,
                    selectedItem: $store.selectedItem,
                    namespace: namespace
                )
            }
            .padding(.horizontal, 15)
        }
        .background(Color.background)
        .task {
            send(.onTask)
        }
        .fullScreenCover(item: $store.selectedItem) { item in
            MediaDetailView(
                media: item,
                navigationTransitionConfig: .init(namespace: namespace, source: item)
            )
        }
    }
}

#Preview {
    HomeScreen(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
    .loadCustomFonts()
}
