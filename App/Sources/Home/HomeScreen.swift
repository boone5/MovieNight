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

    private let sectionSpacing: CGFloat = 15

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

                if !store.isOnboardingComplete {
                    OnboardingGrid(store: store.scope(state: \.onboardingGrid, action: \.onboardingGrid))
                        .padding(.top, sectionSpacing)
                }

                Text("In Theaters Now")
                    .font(.montserrat(size: 18, weight: .semibold))
                    .padding(.top, sectionSpacing)

                FilmRow(
                    items: store.nowPlaying,
                    selectedItem: $store.selectedItem,
                    namespace: namespace
                )

                Text("Coming Soon")
                    .font(.montserrat(size: 18, weight: .semibold))
                    .padding(.top, sectionSpacing)

                ComingSoonRow(
                    items: store.upcoming,
                    selectedItem: $store.selectedItem,
                    namespace: namespace,
                    onAddToCollection: { send(.comingSoonAddToCollectionTapped($0)) }
                )

                Text("Trending Movies")
                    .font(.montserrat(size: 18, weight: .semibold))
                    .padding(.top, sectionSpacing)

                FilmRow(
                    items: store.trendingMovies,
                    selectedItem: $store.selectedItem,
                    namespace: namespace
                )

                Text("Trending TV Shows")
                    .font(.montserrat(size: 18, weight: .semibold))
                    .padding(.top, sectionSpacing)

                FilmRow(
                    items: store.trendingTVShows,
                    selectedItem: $store.selectedItem,
                    namespace: namespace
                )
            }
            .padding(.horizontal, PLayout.horizontalMarginPadding)
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
        .sheet(item: $store.scope(state: \.addToCollection, action: \.addToCollection)) { store in
            AddToCollectionSheet(store: store)
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
