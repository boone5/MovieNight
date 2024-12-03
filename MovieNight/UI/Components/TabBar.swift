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
            MockLibraryScreen(movieDataStore: movieDataStore)
                .tabItem {
                    Label("", systemImage: "books.vertical")
                }
//                .toolbarBackground(Color("BackgroundColor1"), for: .tabBar)

            SearchScreen(movieDataStore: movieDataStore)
                .tabItem {
                    Label("", systemImage: "magnifyingglass")
                }
//                .toolbarBackground(Color("BackgroundColor1"), for: .tabBar)
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageScreen()
    }
}
