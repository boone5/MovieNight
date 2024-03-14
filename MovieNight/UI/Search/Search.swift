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
                            MovieRowView(searchViewModel: searchViewModel, details: detail)
                                .listRowBackground(Color.clear)
                        }

                        Text("End of List")
                            .foregroundStyle(.white)
                            .listRowBackground(Color.clear)
                            .task {
                                if searchViewModel.shouldLoadMore() {
                                    await searchViewModel.loadMore()
                                }
                            }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .navigationDestination(for: SearchResponse.Movie.self) { movie in
                        let imgData = ImageCache.shared.getObject(forKey: movie.posterPath)
                        MovieDetailView(path: $path, imgData: imgData, movieID: movie.id)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .scrollDismissesKeyboard(.immediately)
            }
        }
        
    }
}

struct MovieRowView: View {
    @ObservedObject var searchViewModel: SearchViewModel

    let details: SearchResponse.Movie

    var body: some View {
        NavigationLink(value: details) {
            HStack {
                ThumbnailView(url: details.posterPath, width: 100, height: 150)

                VStack(alignment: .leading, spacing: 5) {
                    Text(details.title)
                        .font(.title2)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .padding(.leading, 15)

                    Text(details.releaseDate)
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundStyle(Color(uiColor: UIColor.systemGray))
                        .padding(.leading, 15)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    Search()
}
