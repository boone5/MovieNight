//
//  LandingPage.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import SwiftUI

struct TabBarView: View {
    private let movieDataStore = MovieDataStore()

    var body: some View {
        TabView {
            Group {
                LibraryScreen(movieDataStore: movieDataStore)
                    .tabItem {
                        Label("", systemImage: "books.vertical")
                    }

                SearchScreen(movieDataStore: movieDataStore)
                    .tabItem {
                        Label("", systemImage: "magnifyingglass")
                    }
            }
            .toolbarBackground(Color(.backgroundColor2), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageScreen()
    }
}
