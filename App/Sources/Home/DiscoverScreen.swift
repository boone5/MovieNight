//
//  DiscoverScreen.swift
//  MovieNight
//
//  Created by Boone on 11/26/25.
//

import ComposableArchitecture
import Models
import Networking
import SwiftUI
import UI

/*
NOT FOR AI:
 - Experiement with average color background of coming soon row
 - last element in ComingSoon array isn't positioned correctly
 */

@ViewAction(for: DiscoverFeature.self)
struct DiscoverScreen: View {
    @Bindable var store: StoreOf<DiscoverFeature>

    @Namespace private var namespace

    private let sectionSpacing: CGFloat = 15

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
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
                }

                FilmRow(
                    sectionTitle: "In Theaters Now",
                    items: store.nowPlaying,
                    selectedItem: $store.selectedItem,
                    namespace: namespace
                )

                VStack(alignment: .leading) {
                    Text("Coming Soon")
                        .font(.montserrat(size: 18, weight: .semibold))

                    ComingSoonRow(
                        items: store.upcoming,
                        selectedItem: $store.selectedItem,
                        namespace: namespace,
                        onAddToCollection: { send(.comingSoonAddToCollectionTapped($0)) }
                    )
                }

                FilmRow(
                    sectionTitle: "Trending Movies",
                    items: store.trendingMovies,
                    selectedItem: $store.selectedItem,
                    namespace: namespace
                )

                FilmRow(
                    sectionTitle: "Trending TV Shows",
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
        .fullScreenCover(item: $store.selectedItem) { selected in
            MediaDetailView(
                media: selected.item,
                navigationTransitionConfig: .init(namespace: namespace, source: selected)
            )
        }
        .sheet(item: $store.scope(state: \.addToCollection, action: \.addToCollection)) { store in
            AddToCollectionSheet(store: store)
        }
    }
}

#Preview {
    DiscoverScreen(
        store: Store(initialState: DiscoverFeature.State()) {
            DiscoverFeature()
        }
    )
    .loadCustomFonts()
}
