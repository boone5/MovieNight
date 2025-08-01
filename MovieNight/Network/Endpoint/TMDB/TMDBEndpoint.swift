//
//  TMDBEndpoint.swift
//  MovieNight
//
//  Created by Boone on 2/8/24.
//

import Foundation

enum TMDBEndpoint: EndpointProviding {
    case movieDetails(id: Int64)
    case tvShowDetails(id: Int64)
    case trendingMovies
    case trendingTVShows
}

extension TMDBEndpoint {
    var apiKey: String {
        APIKey.authorization_TMDB
    }
    
    public func host() -> String {
        "api.themoviedb.org"
    }
    
    func path() -> String {
        switch self {
        case .movieDetails(let id):
            "/3/movie/\(id)"
        case .tvShowDetails(let id):
            "/3/tv/\(id)"
        case .trendingMovies:
            "/3/trending/movie/day"
        case .trendingTVShows:
            "/3/trending/tv/day"
        }
    }

    func queryItems() -> [URLQueryItem]? {
        switch self {
        case .movieDetails:
            [.init(name: "append_to_response", value: "videos,credits")]
        case .tvShowDetails, .trendingMovies, .trendingTVShows:
            nil
        }
    }
}
