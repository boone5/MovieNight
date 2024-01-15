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

    let provider = MovieProvider.shared

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                SearchBox(searchViewModel: searchViewModel)
                    .padding(.top, 30)
                    .padding([.leading, .trailing], 20)

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
                            if searchViewModel.shouldLoadMore(comparing: details), searchViewModel.state != .fetching {
                                await searchViewModel.loadMore()
                            }
                        }
                }
                .listRowBackground(Color.clear)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .navigationDestination(for: MovieResponseTMDB.Details.self) { details in
                    MovieDetailView(path: $path, details: details)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct MovieRowView: View {
    @ObservedObject var searchViewModel: SearchViewModel

    let details: MovieResponseTMDB.Details

    var body: some View {
        NavigationLink(value: details) {
            HStack {
                ThumbnailView(url: details.posterPath)

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

struct ThumbnailView: View {
    @StateObject var thumbnailViewModel = ThumbnailViewModel()

    let url: String?

    var body: some View {
        VStack(spacing: 0) {
            if let imgData = thumbnailViewModel.data, let uiimage = UIImage(data: imgData) {
                Image(uiImage: uiimage)
                    .resizable()
                    .frame(width: 100, height: 150)
                    .scaledToFit()
                    .cornerRadius(15)
            } else {
                Rectangle()
                    .frame(width: 100, height: 150)
                    .cornerRadius(15)
            }
        }
        .task {
            await thumbnailViewModel.load(url)
        }
    }
}

#Preview {
    Search()
}
