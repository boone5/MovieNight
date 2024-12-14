//
//  MovieNightApp.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import SwiftUI

@main
struct MovieNightApp: App {
    @StateObject var movieDataStore = MovieDataStore()

    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(movieDataStore)
//            Search()
        }
    }
}

struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue = ImageLoader()
}

extension EnvironmentValues {
    var imageLoader: ImageLoader {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self ] = newValue}
    }
}
