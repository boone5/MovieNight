//
//  Search.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import SwiftUI

struct Search: View {
    @ObservedObject var movieViewModel: MovieViewModel = MovieViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            SearchBoxView()
                .padding(.top, 30)

            Spacer()

            // MARK: TODO - Debouncer
//            ForEach(movieViewModel.movieResponse.results, id: \.?._id) { movie in
//                VStack {
//                    Text(movie?.titleText?.text ?? "No name")
//                }
//            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.9)
        // This will need to be moved when search function works. we don't want to search right when this view loads.
        .task {
            await movieViewModel.fetchMovies()
        }
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        Search()
    }
}
