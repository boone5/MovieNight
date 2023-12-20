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

                switch searchViewModel.state {
                case .undefined:
                    HStack {
                        Spacer()
                        Text("Recent Searches")
                        Spacer()
                    }
                    .padding(.top, 30)
                case .loading:
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.top, 30)
                case .completed:
                    Spacer()

                    List {
                        ForEach(searchViewModel.movieCells.compactMap { $0 }, id: \.uuid) { movie in
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

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    Search()
}

struct SearchResult: View {
    let movie: MovieResult

    var body: some View {
        NavigationLink(value: movie) {
            HStack {
                if let imgData = movie.thumbnail?.imgData, let uiimage = UIImage(data: imgData) {
                    Image(uiImage: uiimage)
                        .resizable()
                        .frame(width: 100, height: 150)
                        .scaledToFit()
                        .cornerRadius(15)
                } else {
                    // unable to convert image data.. maybe handle in network layer
                    Text("Loading")
                }

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
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//struct ThumbnailView: View {
//    @StateObject var thumbnailViewModel = ThumbnailViewModel()
//
//    let url: String?
//
//    var body: some View {
//        VStack(spacing: 0) {
//            if let data = thumbnailViewModel.data, let uiimage = UIImage(data: data) {
//                Image(uiImage: uiimage)
//                    .resizable()
//                    .frame(width: 100, height: 150)
//                    .scaledToFit()
//                    .cornerRadius(15)
//            } else {
//                Text("Loading")
//            }
//        }
//        .task {
//            await thumbnailViewModel.load(url)
//        }
//    }
//}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        Search()
    }
}
