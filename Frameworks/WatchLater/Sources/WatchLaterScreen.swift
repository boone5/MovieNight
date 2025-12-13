//
//  WatchLaterScreen.swift
//  MovieNight
//
//  Created by Boone on 3/29/25.
//

import Dependencies
import Models
import Networking
import SwiftUI
import UI

public struct WatchLaterScreen: View {
    @State private var navigationPath = NavigationPath()
    @State private var navigateToWatchWheel = false
    @State var selectedFilm: SelectedFilm?
    @State private var headerOpacity: Double = 1.0
    @Namespace private var namespace

    @State private var searchText: String = ""

    @FetchRequest(
        entity: Film.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Film.dateWatched, ascending: true)],
        predicate: NSPredicate(format: "collection.id == %@", FilmCollection.watchLaterID as CVarArg)
    )
    private var watchList: FetchedResults<Film>

    public init() {}

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            BackgroundColorView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        // Custom header
                        NavigationHeader(title: "Watch Later")

                        if !watchList.isEmpty {
                            if watchList.count == 1 {
                                singleItemCTA
                                    .onTapGesture {
                                        if let film = watchList.first {
                                            selectedFilm = SelectedFilm(film: film)
                                        }
                                    }
                            } else {
                                wheelSpinCTA
                                    .onTapGesture {
                                        navigateToWatchWheel = true
                                    }
                            }

                            WatchList(
                                watchList: Array(watchList),
                                namespace: namespace,
                                selectedFilm: $selectedFilm
                            )
                        } else {
                            noContentView
                        }
                    }
                    .padding(.horizontal, 15)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationDestination(isPresented: $navigateToWatchWheel) {
                WheelView(films: Array(watchList))
            }
            .fullScreenCover(item: $selectedFilm) { selectedFilm in
                FilmDetailView(
                    film: selectedFilm.film,
                    navigationTransitionConfig: .init(namespace: namespace, source: selectedFilm.film)
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
}

import CoreData

#Preview {
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
                film.collection =  watchList
                film.posterPath = "/dKL78O9zxczVgjtNcQ9UkbYLzqX.jpg"
            }
            return context
        }()

        var body: some View {
            WatchLaterScreen()
                .environment(\.managedObjectContext, context)
        }
    }

    return WatchLaterScreenPreviews()
}
