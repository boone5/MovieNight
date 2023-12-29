//
//  Search.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import SwiftUI

struct Search: View {
    @StateObject var searchViewModel: SearchViewModel = SearchViewModel()

    @State var path: NavigationPath = NavigationPath()

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

                List {
                    ForEach(searchViewModel.movie?.results ?? [], id: \.id) { movie in
                        SearchResult(searchViewModel: searchViewModel, result: movie)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .navigationDestination(for: MovieResultTMDB.self) { movie in
                    SearchResultDetailView(movie: movie, path: $path)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct SearchResult: View {
    @ObservedObject var searchViewModel: SearchViewModel

    let result: MovieResultTMDB

    var body: some View {
        NavigationLink(value: result) {
            HStack {
                ThumbnailView(url: result.posterPath)

                VStack(alignment: .leading, spacing: 5) {
                    Text(result.title)
                        .font(.title2)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .padding(.leading, 15)

                    Text(result.releaseDate)
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundStyle(Color(uiColor: UIColor.systemGray))
                        .padding(.leading, 15)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .task {
//                if searchViewModel.shouldRequestNewPage(comparing: result), !searchViewModel.isFetching {
//                    await searchViewModel.fetchNextPage()
//                }
            }
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
