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

    var body: some View {
        TabView(selection: $store.selectedTab) {
            Tab("Home", systemImage: "house", value: .home) {
                HomeScreen()
                    .environment(\.managedObjectContext, MovieProvider.shared.container.viewContext)
            }

            Tab("Library", systemImage: "books.vertical", value: .library) {
                LibraryScreen()
                    .environment(\.managedObjectContext, MovieProvider.shared.container.viewContext)
            }

            Tab("Watch Later", systemImage: "chart.pie", value: .watchLater) {
                UpNextScreen()
                    .environment(\.managedObjectContext, MovieProvider.shared.container.viewContext)
            }

            Tab("Search", systemImage: "magnifyingglass", value: .search, role: .search) {
                NavigationStack {
                    SearchScreen()
                }
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
