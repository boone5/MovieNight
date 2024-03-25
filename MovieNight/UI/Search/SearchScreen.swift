//
//  Search.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import SwiftUI

struct Search: View {
    @StateObject var searchViewModel: SearchViewModel = SearchViewModel()
    @State private var path: NavigationPath = NavigationPath()
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack(path: $path) {
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
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Explore")
                            .foregroundStyle(.white)
                            .font(.system(size: 42, weight: .bold))

                        CustomSearchBar(vm: searchViewModel, searchText: $searchText)
                        // no way to adjust default padding from UISearchBar https://stackoverflow.com/questions/55636460/remove-padding-around-uisearchbar-textfield
                            .padding(.horizontal, -8)
                    }
                    .padding([.leading, .trailing], 15)

                    Spacer()

                    if searchViewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.top, 30)
                    }

                    List {
                        ForEach(searchViewModel.movieDetails) { detail in
                            Group {
                                HStack {
                                    switch detail {
                                    case .movie(let movie):
                                        NavigationLink {
                                            MovieDetailScreen(viewModel: MovieDetailViewModel(movie: movie), path: $path)
                                        } label: {
                                            MovieRowView(movie: movie)
                                        }
                                    case .tvShow(let tvShow):
                                        NavigationLink {
                                            TVShowDetailScreen(viewModel: TVShowDetailViewModel(tvShow: tvShow), path: $path)
                                        } label: {
                                            TVShowRowView(tvShow: tvShow)
                                        }
                                    case .people(let actorResponse):
                                        Text("Person")
                                            .foregroundStyle(.white)
                                    }

                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .listRowBackground(Color.clear)
                            .buttonStyle(PlainButtonStyle())
                        }

                        Text("End of List")
                            .foregroundStyle(.white)
                            .listRowBackground(Color.clear)
                            .task {
                                await searchViewModel.loadMore()
                            }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .scrollDismissesKeyboard(.immediately)
            }
        }
    }
}

struct TVShowRowView: View {
    let tvShow: TVShowResponse

    var body: some View {
        ThumbnailView(url: tvShow.posterPath, width: 100, height: 150)

        VStack(alignment: .leading, spacing: 5) {
            Text(tvShow.title)
                .font(.title2)
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundStyle(Color(uiColor: .white))
                .padding(.leading, 15)

            Text(tvShow.firstAirDate)
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(Color(uiColor: .systemGray))
                .padding(.leading, 15)

            Text(tvShow.mediaType)
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(Color(uiColor: .systemGray))
                .padding(.leading, 15)
        }
    }
}

struct MovieRowView: View {
    let movie: MovieResponse

    var body: some View {
        ThumbnailView(url: movie.posterPath, width: 100, height: 150)

        VStack(alignment: .leading, spacing: 5) {
            Text(movie.title)
                .font(.title2)
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundStyle(Color(uiColor: .white))
                .padding(.leading, 15)

            Text(movie.releaseDate)
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(Color(uiColor: .systemGray))
                .padding(.leading, 15)

            Text(movie.mediaType)
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(Color(uiColor: .systemGray))
                .padding(.leading, 15)
        }
    }
}

#Preview {
    Search()
}
