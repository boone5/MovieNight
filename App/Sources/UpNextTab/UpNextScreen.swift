//
//  UpNextScreen.swift
//  MovieNight
//
//  Created by Boone on 3/29/25.
//

import Dependencies
import Models
import Networking
import SwiftUI
import UI

struct UpNextScreen: View {
    @State private var navigationPath = NavigationPath()
    @State private var navigateToWatchWheel = false
    @State var selectedFilm: SelectedFilm?
    @State private var headerOpacity: Double = 1.0
    @Namespace private var namespace

    @FetchRequest(
        entity: Film.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Film.dateWatched, ascending: true)],
        predicate: NSPredicate(format: "collection.id == %@", FilmCollection.watchLaterID as CVarArg)
    )
    private var watchList: FetchedResults<Film>

    var body: some View {
        NavigationStack(path: $navigationPath) {
            BackgroundColorView {
                ScrollView {
                    VStack(alignment: .leading) {
                        // Custom header
                        Text("Watch Later")
                            .font(.largeTitle.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(headerOpacity)
                            .onGeometryChange(for: CGFloat.self) { proxy in
                                proxy.frame(in: .scrollView).minY
                            } action: { minY in
                                // how many points until fully invisible
                                print(minY)
                                let fadeThreshold = 50.0
                                headerOpacity = max(0, min(1, (minY + fadeThreshold) / fadeThreshold))
                            }
                            .padding(.bottom, 10)

                        HStack(spacing: 10) {
                            Image(systemName: "chart.pie")
                                .resizable()
                                .frame(width: 30, height: 30)

                            VStack(alignment: .leading) {
                                Text("Watch Wheel")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Not sure what to watch?")
                                    .font(.system(size: 14, weight: .medium))
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(10)
                        .background {
                            Color.gray
                        }
                        .clipShape(.rect(cornerRadius: 12))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            navigateToWatchWheel = true
                        }

                        Group {
                            if watchList.isEmpty {
                                Text("TODO: CTA")
                            } else {
                                WatchList(
                                    watchList: Array(watchList),
                                    namespace: namespace,
                                    selectedFilm: $selectedFilm
                                )
                            }
                        }
                        .padding(.top, 10)

                        Spacer()
                    }
                    .padding(.horizontal, 15)
                }
            }
            .navigationDestination(isPresented: $navigateToWatchWheel) {
                WheelView(films: Array(watchList))
            }
            .opacity(selectedFilm != nil ? 0 : 1)
            .overlay {
                if let selectedFilm {
                    FilmDetailView(
                        film: selectedFilm.film,
                        namespace: namespace
                    ) {
                        self.selectedFilm = nil
                    }
                    .transition(.asymmetric(insertion: .identity, removal: .opacity))
                }
            }
            .toolbar(selectedFilm != nil ? .hidden : .visible, for: .tabBar)
        }
    }
}

import CoreData

#Preview {
    struct UpNextScreenPreviews: View {
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
            }
            return context
        }()

        var body: some View {
            UpNextScreen()
                .environment(\.managedObjectContext, context)
        }
    }

    return UpNextScreenPreviews()
}
