//
//  MovieNightApp.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import ComposableArchitecture
import Networking
import SwiftUI
import UI

@main
struct MovieNightApp: App {

    @MainActor
    static let store: StoreOf<AppFeature> = {
        let store = Store(initialState: AppFeature.State(), reducer: AppFeature.init)
        @Dependency(\.movieProvider) var movieProvider
        try? movieProvider.prepareDefaultCollections()
        return store
    }()

    init() {
        CustomFonts.register()
    }

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
