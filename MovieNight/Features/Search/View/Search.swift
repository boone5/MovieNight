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
                            NavigationLink(value: movie) {
                                SearchResult(movie: movie!)
                            }
                            .buttonStyle(PlainButtonStyle())
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
                    .navigationDestination(for: Movie.self) { movie in
                        Text("Destination")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding([.leading, .trailing], 20)
        }
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        Search()
    }
}
