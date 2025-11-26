//
//  LandingPage.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import SwiftUI

struct TabBarView: View {
    @State private var showSearchTitle = true

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
    TabBarView()
}
