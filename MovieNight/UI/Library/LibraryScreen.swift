//
//  MockLibraryScreen.swift
//  MovieNight
//
//  Created by Boone on 6/30/24.
//

import SwiftUI

struct LibraryScreen: View {
    @StateObject private var viewModel: LibraryScreen.ViewModel

    @Namespace private var namespace

    init(movieDataStore: MovieDataStore) {
        _viewModel = StateObject(wrappedValue: LibraryScreen.ViewModel(movieDataStore: movieDataStore))
    }

    let layout = [
        GridItem(.adaptive(minimum: 120)),
        GridItem(.adaptive(minimum: 120)),
    ]

    enum MovieCollection: Identifiable, CaseIterable {
        var id: String { UUID().uuidString }

        case movies
        case tvShows
        case watchLater

        var title: String {
            switch self {
            case .movies:
                return "Movies"
            case .tvShows:
                return "TV Shows"
            case .watchLater:
                return "Watch Later"
            }
        }

        var count: Int {
            switch self {
            case .movies:
                return 10
            case .tvShows:
                return 20
            case .watchLater:
                return 5
            }
        }
    }

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
                VStack(alignment: .center, spacing: 0) {
                    HStack(spacing: 10) {
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)

                        Text("hunter")
                            .foregroundStyle(.white)
                            .font(.system(size: 18, weight: .regular))

                        Spacer()

                        Button {
                            //
                        } label: {

                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                        }
                    }
                    .padding(.top, 15)
                }
                .padding(15)
                .background {
                    Color("BackgroundColor1").ignoresSafeArea()
                        .shadow(color: .black, radius: 10, y: -2)
                }

                if viewModel.movies.isEmpty {
                    Spacer()
                    Text("Start watching Movies and TV shows to build your library.")
                        .font(.system(size: 14, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                    Spacer()

                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Recently Watched")
                                .foregroundStyle(.white)
                                .font(.system(size: 22, weight: .semibold))
                                .padding([.leading, .bottom], 15)
                                .padding(.top, 15)

                            

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(viewModel.movies, id: \.id) { movie in
                                        ThumbnailView(
                                            url: movie.posterPath,
                                            id: movie.id,
                                            width: 175,
                                            height: 250,
                                            namespace: namespace
                                        )
                                    }
                                }
                                .padding(.leading, 15)
                            }

                            Text("Collections")
                                .foregroundStyle(.white)
                                .font(.system(size: 22, weight: .semibold))
                                .padding(.top, 30)
                                .padding(.bottom, 20)
                                .padding([.leading, .trailing], 15)

                            LazyVGrid(columns: layout) {
                                // Movies, TV Shows, Watch Later
                                ForEach(MovieCollection.allCases) { type in
                                    HStack {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .frame(width: 40, height: 60)
                                                .foregroundStyle(.red)
                                                .scaleEffect(0.8)
                                                .offset(x: 15)

                                            RoundedRectangle(cornerRadius: 8)
                                                .frame(width: 40, height: 60)
                                                .foregroundStyle(.blue)
                                                .scaleEffect(0.9)
                                                .offset(x: 8)

                                            RoundedRectangle(cornerRadius: 8)
                                                .frame(width: 40, height: 60)
                                                .foregroundStyle(.green)
                                        }

                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(type.title)
                                                .foregroundStyle(Color(uiColor: MovieNightColors.subtitle))
                                                .font(.system(size: 12, weight: .medium))

                                            // MARK: TODO - Add red background for Watch Later
                                            Text(String(type.count))
                                                .foregroundStyle(Color(uiColor: MovieNightColors.body))
                                                .font(.system(size: 10, weight: .regular))
                                        }
                                        .padding(.leading, 20)

                                        Spacer()
                                    }
                                    .padding(15)
                                    .background {
                                        RoundedRectangle(cornerRadius: 25)
                                            .foregroundStyle(Color(.brightRed).opacity(0.4))
                                    }
                                }
                            }
                            .padding([.leading, .trailing], 15)

                        }
                    }
                }
            }

        }
        .onAppear {
            viewModel.fetchRecentlyWatched()
        }
    }
}

//#Preview {
//    MockLibraryScreen()
//}

extension LibraryScreen {
    class ViewModel: ObservableObject {
        @Published var movies: [MovieData] = []
        private let movieDataStore: MovieDataStore

        init(movieDataStore: MovieDataStore = MovieDataStore()) {
            self.movieDataStore = movieDataStore
        }

        func fetchRecentlyWatched() {
            let movies = movieDataStore.fetchMoviesSortedByDateWatched()
            self.movies = movies.map { MovieData(from: $0) }
        }
    }
}
