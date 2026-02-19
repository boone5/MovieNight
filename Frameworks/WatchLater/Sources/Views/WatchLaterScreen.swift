//
//  WatchLaterScreen.swift
//  MovieNight
//
//  Created by Boone on 3/29/25.
//

import ComposableArchitecture
import Models
import Networking
import SwiftUI
import UI

@ViewAction(for: WatchLaterFeature.self)
public struct WatchLaterScreen: View {
    @Bindable public var store: StoreOf<WatchLaterFeature>

    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateCreated, order: .forward)])
    private var collections: FetchedResults<FilmCollection>

    public init(store: StoreOf<WatchLaterFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.navigationPath) {
            if !collections.isEmpty {
                WheelView(store: store, collections: collections)
            } else {
                noContentView
            }
        }
    }

    private var noContentView: some View {
        VStack {
            Image(systemName: "popcorn")
                .font(.system(size: 60))

            Text("Your collections are empty!")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 8)
            Text("Browse movies and TV shows to add them to your collections.")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.vertical, 4)

            Button {
                // TODO: Navigate to the search or home screen
            } label: {
                Label("Browse Now", systemImage: "magnifyingglass")
                    .font(.system(size: 16, weight: .bold))
                    .tint(.primary)
                    .padding()
                    .glassEffect(.regular.interactive())
            }
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, minHeight: 500)
    }
}

import CoreData

#Preview {
    prepareDependencies {
        $0.imageLoader = ImageLoaderClient.liveValue
    }
    struct WatchLaterScreenPreviews: View {
        let context: NSManagedObjectContext = {
            @Dependency(\.movieProvider) var movieProvider
            let context = movieProvider.container.viewContext
            let watchList = FilmCollection(context: context)
            watchList.id = FilmCollection.watchLaterID

            for i in 0..<3 {
                let film = Film(context: context)
                film.id = Int64(i)
                film.title = "Mock Film \(i)"
                film.addToCollections(watchList)
                film.posterPath = "/dKL78O9zxczVgjtNcQ9UkbYLzqX.jpg"
            }
            return context
        }()

        var body: some View {
            WatchLaterScreen(store: .init(initialState: WatchLaterFeature.State(), reducer: WatchLaterFeature.init))
                .environment(\.managedObjectContext, context)
        }
    }

    return TabView {
        Tab("Watch Later", systemImage: "clock") {
            WatchLaterScreenPreviews()
        }

        Tab("test", systemImage: "magnifyingglass", role: .search) {
            Text("Test")
        }
    }
}
