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
            VStack(alignment: .leading, spacing: 15) {
                SearchBox(searchViewModel: searchViewModel)
                    .padding(.top, 30)

                Spacer()

                ScrollView(.vertical, showsIndicators: true) {
                    #warning("TODO: Change to custom List?")
                    LazyVStack(alignment: .leading) {
                        #if DEBUG
                        ForEach(MovieMocks().generateMovies(count: 1).results, id: \.?._id) { movie in
                            SearchResult(movie: movie!)
                        }
                        #elseif RELEASE
                        #warning("TODO: If results are nil, show appropiate message")
                        ForEach(searchViewModel.movieResponse.results, id: \.?._id) { movie in
                            NavigationLink(value: movie) {
                                SearchResult(movie: movie!)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        #endif
                    }
                    .navigationDestination(for: MovieResult.self) { movie in
                        SearchResultDetailView(movie: movie, path: $path)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding([.leading, .trailing], 20)
        }
    }
}

struct SearchResult: View {
    let movie: MovieResult

    var body: some View {
        NavigationLink(value: movie) {
            HStack {
                ThumbnailView(url: movie.thumbnail?.url)
                    .frame(width: 100, height: 150)
                    .scaledToFit()
                    .cornerRadius(15)

                VStack(alignment: .leading, spacing: 5) {
                    Text(movie.titleText?.text ?? "hello")
                        .font(.title2)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .padding(.leading, 15)

                    Text(String(movie.releaseYear?.year ?? -1))
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundStyle(Color(uiColor: UIColor.systemGray))
                        .padding(.leading, 15)
                }

                Spacer()

                Image(systemName: "chevron.right")
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
            if let data = thumbnailViewModel.data, let uiimage = UIImage(data: data) {
                Image(uiImage: uiimage)
                    .resizable()
                    .frame(width: 100, height: 150)
                    .scaledToFit()
                    .cornerRadius(15)
            } else {
                Text("Loading")
            }
        }
        .task {
            await thumbnailViewModel.load(url)
        }
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        Search()
    }
}
