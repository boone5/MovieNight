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
            #warning("TODO: Implement a Cache")
            AsyncImage(url: URL(string: movie.thumbnail?.url ?? "no image")) { phase in
                if let image = phase.image {
                    image.resizable()
                } else if let _ = phase.error {
                    Color.red
                } else {
                    Color.blue
                }
            }
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
}

#Preview {
    SearchResult(movie: Movie(releaseYear: Movie.ReleaseYear(endYear: nil, year: 2023)))
}
