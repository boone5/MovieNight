//
//  Search.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import SwiftUI

struct Search: View {
    @StateObject var searchViewModel: SearchViewModel = SearchViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SearchBox(searchViewModel: searchViewModel)
                .padding(.top, 30)

            Spacer()

            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(alignment: .leading) {
                    #warning("TODO: If results are nil, show appropiate message")
                    ForEach(searchViewModel.movieResponse.results, id: \.?._id) { movie in
                        SearchResult(movie: movie!)
                    }
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.9)
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        Search()
    }
}
