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

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    @Dependency(\.movieProvider.container.viewContext) var context

    var body: some View {
        TabView(selection: $store.selectedTab) {
            Tab(AppTab.home.label, systemImage: AppTab.home.icon, value: .home) {
                HomeScreen()
                    .environment(\.managedObjectContext, context)
            }

            Tab(AppTab.library.label, systemImage: AppTab.library.icon, value: .library) {
                LibraryScreen()
                    .environment(\.managedObjectContext, context)
            }

            Tab(AppTab.watchLater.label, systemImage: AppTab.watchLater.icon, value: .watchLater) {
                UpNextScreen()
                    .environment(\.managedObjectContext, context)
            }

            Tab(AppTab.search.label, systemImage: AppTab.search.icon, value: .search, role: .search) {
                SearchScreen()
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
        case .home: "Home"
        case .library: "Library"
        case .watchLater: "Watch Later"
        case .search: "Search"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .library: "books.vertical"
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
