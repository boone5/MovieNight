//
//  APIEndpoint.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

enum APIEndpoint {
    case fetchMovieByTitle(_ title: String)
    case fetchMovieThumbnail(_ url: String)

    var path: String {
        switch self {
        case .fetchMovieByTitle(let title):
            let replacedString = title.replacingOccurrences(of: " ", with: "%20")
            #warning("TODO: Implement URL Builder for applied filters")
            return "https://moviesdatabase.p.rapidapi.com/titles/search/title/\(replacedString)?exact=false&titleType=movie"

        case .fetchMovieThumbnail(let url):
            return url
        }
    }
}
