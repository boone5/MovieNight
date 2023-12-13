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

                Spacer()

                List {
                    #warning("TODO: If results are nil, show appropiate message")
                    ForEach(searchViewModel.movieCells.enumerated().map(\.element), id: \.0) { movie in
                        SearchResult(movie: movie)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .navigationDestination(for: MovieResult.self) { movie in
                    SearchResultDetailView(movie: movie, path: $path)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    Search()
}

struct SearchResult: View {
    let movie: (MovieResult?, UIImage?)

    var body: some View {
        NavigationLink(value: movie.0) {
            HStack {

                if let image = movie.1 {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 150)
                        .scaledToFit()
                        .cornerRadius(15)
                } else {
                    Text("Loading")
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(movie.0?.titleText?.text ?? "hello")
                        .font(.title2)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .padding(.leading, 15)

                    Text(String(movie.0?.releaseYear?.year ?? -1))
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
