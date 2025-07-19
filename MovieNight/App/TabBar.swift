//
//  LandingPage.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            Group {
                LibraryScreen()
                    .tabItem {
                        Label("Library", systemImage: "books.vertical")
                    }
                    .environment(\.managedObjectContext, MovieProvider.shared.container.viewContext)

                SearchScreen()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }

                UpNextScreen()
                    .tabItem {
                        Label("Up Next", systemImage: "chart.pie")
                    }
                    .environment(\.managedObjectContext, MovieProvider.shared.container.viewContext)
            }
            .toolbarBackground(Color(.backgroundColor2), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
}

#Preview {
    TabBarView()
}
