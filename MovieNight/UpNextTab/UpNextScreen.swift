//
//  UpNextScreen.swift
//  MovieNight
//
//  Created by Boone on 3/29/25.
//

import SwiftUI

struct UpNextScreen: View {
    @State private var navigationPath = NavigationPath()
    @State private var navigateToWatchWheel = false
    @State var isExpanded: Bool = false
    @State var selectedFilm: SelectedFilm?
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
                        .padding(.top, 20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            navigateToWatchWheel = true
                        }

                        Text("Watch Later")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.top, 20)

                        Group {
                            if watchList.isEmpty {
                                Text("TODO: CTA")
                            } else {
                                WatchList(
                                    watchList: Array(watchList),
                                    namespace: namespace,
                                    isExpanded: $isExpanded,
                                    selectedFilm: $selectedFilm
                                )
                            }
                        }
                        .padding(.top, 10)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationDestination(isPresented: $navigateToWatchWheel) {
                WheelView(films: Array(watchList))
            }
            .opacity(isExpanded ? 0 : 1)
            .overlay {
                if let selectedFilm, isExpanded {
                    FilmDetailView(
                        film: selectedFilm.film,
                        namespace: namespace,
                        isExpanded: $isExpanded,
                        uiImage: selectedFilm.posterImage
                    )
                    .transition(.asymmetric(insertion: .identity, removal: .opacity))
                }
            }
            .toolbar(isExpanded ? .hidden : .visible, for: .tabBar)
        }
    }
}

#Preview {
    let context = MovieProvider.preview.container.viewContext
    let watchList = FilmCollection(context: context)
    watchList.id = FilmCollection.watchLaterID

    for i in 0..<3 {
        let film = Film(context: context)
        film.id = Int64(i)
        film.title = "Mock Film \(i)"
        film.collection =  watchList
    }

    return UpNextScreen()
        .environment(\.managedObjectContext, context)
}
