//
//  WatchWheelView.swift
//  MovieNight
//
//  Created by Boone on 3/29/25.
//

import SwiftUI

struct WheelScreen: View {
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
        NavigationView {
            BackgroundColorView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        WheelView(films: Array(watchList))

                        Text("Watch List")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.top, 30)

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
                        .padding(.top, 15)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Wheel")
        }
    }
}

#Preview {
    WheelScreen()
}
