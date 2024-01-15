//
//  LandingPage.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import SwiftUI

struct LandingPage: View {
    var body: some View {
        TabView {
            Search()
                .tabItem {
                    Label("", systemImage: "magnifyingglass")
                }

            Library()
                .environment(\.managedObjectContext, MovieProvider.shared.viewContext)
                .tabItem {
                    Label("", systemImage: "books.vertical")
                }
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage()
    }
}
