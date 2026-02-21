//
//  AppView.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import ComposableArchitecture
import Networking
import Search
import SwiftUI
import WatchLater

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    @Dependency(\.movieProvider.container.viewContext) var context

    var body: some View {
        TabView(selection: $store.selectedTab) {
            Tab(AppTab.home.label, systemImage: AppTab.home.icon, value: .home) {
                DiscoverScreen(store: store.scope(state: \.discover, action: \.discover))
                    .environment(\.managedObjectContext, context)
            }

            Tab(AppTab.library.label, systemImage: AppTab.library.icon, value: .library) {
                LibraryScreen(store: store.scope(state: \.library, action: \.library))
                    .environment(\.managedObjectContext, context)
            }

            Tab(AppTab.watchLater.label, systemImage: AppTab.watchLater.icon, value: .watchLater) {
                WatchLaterScreen(store: store.scope(state: \.watchLater, action: \.watchLater))
                    .environment(\.managedObjectContext, context)
            }

            Tab(AppTab.search.label, systemImage: AppTab.search.icon, value: .search, role: .search) {
                SearchScreen(store: store.scope(state: \.search, action: \.search))
            }
        }
    }
}
 
enum AppTab: Hashable {
    case home
    case library
    case watchLater
    case search

    var label: String {
        switch self {
        case .home: "Discover"
        case .library: "Library"
        case .watchLater: "Wheel"
        case .search: "Search"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .library: "rectangle.stack.fill" // TODO: Would be cool to use a rolling film image
        case .watchLater: "chart.pie"
        case .search: "magnifyingglass"
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
