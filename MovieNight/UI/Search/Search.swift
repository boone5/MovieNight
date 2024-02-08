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
                
                List(searchViewModel.movieDetails) { details in
                    MovieRowView(searchViewModel: searchViewModel, details: details)
                        .task {
                            if searchViewModel.shouldLoadMore(comparing: details) {
                                await searchViewModel.loadMore()
                            }
                        }
                }
                .listRowBackground(Color.clear)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .navigationDestination(for: MovieResponseTMDB.Details.self) { details in
                    MovieDetailView(path: $path, viewModel: .init(details: details))
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

    let details: MovieResponseTMDB.Details

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
