//
//  SearchResult.swift
//  MovieNight
//
//  Created by Boone on 9/6/23.
//

import SwiftUI

struct SearchResult: View {
    let movie: Movie

    var body: some View {
        HStack {
            #warning("TODO: Treat a nil URL the same as error case")
            AsyncImage(url: URL(string: movie.thumbnail?.url ?? "no image")) { phase in
                if let image = phase.image {
                    image.resizable()
                } else if let _ = phase.error {
                    #warning("TODO: If error, show placeholder image")
                    Color.red
                } else {
                    #warning("TODO: If loading, show placeholder shimmer")
                    Color.blue
                }
            }
            .frame(width: 125, height: 175)

            Text(movie.titleText?.text ?? "hello")
                .font(.title)
        }
    }
}

struct SearchResult_Previews: PreviewProvider {
    static var previews: some View {
        SearchResult(
            movie:
                Movie(
                    releaseYear: Movie.ReleaseYear(endYear: nil, year: 2020),
                    titleText: Movie.TitleText(text: "Test Movie")
                )
        )
    }
}
