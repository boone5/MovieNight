//
//  MovieNightApp.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import ComposableArchitecture
import Networking
import SwiftUI

@main
struct MovieNightApp: App {
    let movieProvider = MovieProvider.shared

    init() {
        movieProvider.preloadDefaultCollectionsIfNeeded()
    }

    @MainActor
    static let store: StoreOf<AppFeature> = {
        let store = Store(initialState: AppFeature.State(), reducer: AppFeature.init)
        MovieProvider.shared.preloadDefaultCollectionsIfNeeded()
        return store
    }()

    var body: some Scene {
        WindowGroup {
            if !isTesting {
                AppView(store: Self.store)
            } else {
                EmptyView()
            }
        }
    }
}
