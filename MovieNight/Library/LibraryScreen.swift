//
//  MockLibraryScreen.swift
//  MovieNight
//
//  Created by Boone on 6/30/24.
//

import SwiftUI

struct LibraryScreen: View {
    @StateObject private var thumbnailViewModel = ThumbnailView.ViewModel()

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "dateWatched", ascending: false)])
    var movies: FetchedResults<Movie>

    @State var isExpanded: Bool = false
    @State var selectedFilm: SelectedFilm?
    @Namespace private var namespace

    var body: some View {
        ZStack {
            Color.clear
                .background {
                    LinearGradient(
                        colors: [Color("BackgroundColor1"), Color("BackgroundColor2")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 7) {
                    Text("Library")
                        .foregroundStyle(.white)
                        .font(.system(size: 42, weight: .bold))
                        .padding([.leading, .trailing], 15)
                }
                .padding(.top, 15)
                .padding(.bottom, 20)

                if movies.isEmpty {
                    Spacer()
                    Text("Start watching films to build your library.")
                        .font(.system(size: 14, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 15)
                    Spacer()

                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Recently watched")
                                .foregroundStyle(.white)
                                .font(.system(size: 22, weight: .bold))
                                .padding([.leading, .bottom], 15)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(movies, id: \.id) { movie in
                                        if selectedFilm?.id == movie.id, isExpanded {
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(.clear)
                                                .frame(width: 175, height: 250)
                                        } else {
                                            ThumbnailView(
                                                viewModel: thumbnailViewModel,
                                                filmID: movie.id,
                                                posterPath: movie.posterPath,
                                                width: 175,
                                                height: 250,
                                                namespace: namespace
                                            )
                                            .shadow(color: .black.opacity(0.6), radius: 8, y: 4)
                                            .onTapGesture {
                                                withAnimation(.spring()) {
                                                    isExpanded = true
                                                    selectedFilm = SelectedFilm(id: movie.id, film: movie, posterImage: thumbnailViewModel.posterImage(for: movie.posterPath))
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.leading, 15)
                                .padding(.vertical, 15)     // allows space for drop shadow
                            }
                            .padding(.vertical, -15)        // negates space for drop shadow

                            WatchLaterView()
                                .padding(.top, 30)

                            CollectionsView()
                                .padding(.top, 30)
                                .padding([.leading, .trailing], 15)
                        }
                    }
                }
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

//#Preview {
//    MockLibraryScreen()
//}
