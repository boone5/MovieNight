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
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                if searchViewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.top, 30)
                }

                Spacer()

                List {
                    ForEach(searchViewModel.movieDetails) { detail in
                        MovieRowView(searchViewModel: searchViewModel, details: detail)
                    }

                    if !searchViewModel.movieDetails.isEmpty {
                        EmptyView()
                            .task {
                                if searchViewModel.shouldLoadMore() {
                                    await searchViewModel.loadMore()
                                }
                            }
                    }
                }
                .listRowBackground(Color.clear)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .navigationDestination(for: SearchResponse.Movie.self) { movie in
                    let imgData = ImageCache.shared.getObject(forKey: movie.posterPath)
                    MovieDetailView(path: $path, imgData: imgData, movieID: movie.id)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .searchable(text: $searchViewModel.searchQuery)
            .onSubmit(of: .search) {
                Task {
                    await searchViewModel.fetchMovieDetails(for: searchViewModel.searchQuery)
                }
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
