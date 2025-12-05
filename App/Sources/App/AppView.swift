//
//  AppView.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeScreen()
                    .environment(\.managedObjectContext, MovieProvider.shared.container.viewContext)
            }

            Tab("Library", systemImage: "books.vertical") {
                LibraryScreen()
                    .environment(\.managedObjectContext, MovieProvider.shared.container.viewContext)
            }

            Tab("Watch Later", systemImage: "chart.pie") {
                UpNextScreen()
                    .environment(\.managedObjectContext, MovieProvider.shared.container.viewContext)
            }

            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                NavigationStack {
                    SearchScreen()
                }
            }
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
