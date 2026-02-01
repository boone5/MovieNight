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

    @Namespace private var namespace

    @FetchRequest(
        entity: Film.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Film.dateWatched, ascending: true)],
        predicate: NSPredicate(format: "ANY collections.id == %@", FilmCollection.watchLaterID as CVarArg)
    )
    private var watchList: FetchedResults<Film>

    private var items: [MediaItem] { watchList.map(MediaItem.init) }

    private var filteredWatchList: [MediaItem] {
        guard store.searchText.isEmpty == false else {
            return items
        }
        return items.filter {
            $0.title.localizedCaseInsensitiveContains(store.searchText) == true
        }
    }

    @FocusState private var isSearchFieldFocused: Bool

    public init(store: StoreOf<WatchLaterFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.navigationPath) {
            BackgroundColorView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Custom header
                        NavigationHeader(title: "Watch Later")

                        if !watchList.isEmpty {
                            if watchList.count == 1 {
                                singleItemCTA
                                    .onTapGesture {
                                        guard let first = watchList.first else { return }
                                        send(.readyToWatchFilmButtonTapped(.init(from: first)))
                                    }
                            } else {
                                wheelSpinCTA
                                    .onTapGesture {
                                        send(.spinWheelButtonTapped)
                                    }
                            }

                            searchBar

                            WatchList(
                                watchList: filteredWatchList,
                                namespace: namespace,
                                selectedItem: $store.selectedItem
                            )
                            .animation(.default, value: filteredWatchList.count)
                        } else {
                            noContentView
                        }
                    }
                    .padding(.horizontal, 15)
                }
                .scrollBounceBehavior(watchList.isEmpty ? .basedOnSize : .automatic)
                .scrollDismissesKeyboard(.interactively)
            }
            .bind($isSearchFieldFocused, to: $store.isSearchFieldFocused)
            .navigationDestination(for: WatchLaterPath.self) { path in
                switch path {
                case .wheel:
                    WheelView(items: items)
                }
            }
            .fullScreenCover(item: $store.selectedItem) { selectedItem in
                MediaDetailView(
                    media: selectedItem,
                    navigationTransitionConfig: .init(namespace: namespace, source: selectedItem)
                )
            }
        }
    }

    private var noContentView: some View {
        VStack {
            Image(systemName: "popcorn")
                .font(.system(size: 60))

            Text("Your Watch Later list is empty!")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 8)
            Text("Browse movies and TV shows to add them to your Watch Later list.")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.vertical, 4)

            Button {
                // Navigate to the search or home screen
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

    private var wheelSpinCTA: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "chart.pie")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(4)

                    Text("Spin the Wheel")
                        .font(.system(size: 16, weight: .bold))
                }

                Text("Let fate decide what to watch next!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .glassEffect(in: .buttonBorder)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
        .contentShape(Rectangle())
    }

    private var singleItemCTA: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(6)

                    Text("Ready to Watch")
                        .font(.system(size: 16, weight: .bold))
                }

                Text("You’ve only got one pick — let’s go.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
        .contentShape(Rectangle())
    }

    private var searchBar: some View {
        GlassEffectContainer {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary )
                    TextField("Search watch list", text: $store.searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($isSearchFieldFocused)
                }
                .padding(10)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
                
                if isSearchFieldFocused || !store.searchText.isEmpty {
                    Button {
                        send(.clearSearchFieldButtonTapped)
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
                            .padding(8)
                    }
                    .buttonBorderShape(.circle)
                    .buttonStyle(.glass)
                }
            }
        }
        .animation(.default, value: isSearchFieldFocused)
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

        Tab("test", systemImage:"magnifyingglass", role: .search) {
            Text("Test")
        }
    }
}
