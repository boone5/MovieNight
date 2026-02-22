//
//  TMDBEndpoint.swift
//  MovieNight
//
//  Created by Boone on 2/8/24.
//

import Foundation
import Models

public enum TMDBEndpoint: EndpointProviding {
    case movieDetails(id: MediaItem.ID)
    case tvShowDetails(id: MediaItem.ID)
    case personDetails(id: MediaItem.ID)
    case trendingMovies
    case trendingTVShows
    case nowPlaying
    case upcoming(page: Int = 1)
}

public extension TMDBEndpoint {
    var apiKey: String {
        APIKey.authorization_TMDB
    }
    
    func host() -> String {
        "api.themoviedb.org"
    }
    
    func path() -> String {
        switch self {
        case .movieDetails(let id):
            "/3/movie/\(id)"
        case .tvShowDetails(let id):
            "/3/tv/\(id)"
        case .personDetails(let id):
            "/3/person/\(id)"
        case .trendingMovies:
            "/3/trending/movie/day"
        case .trendingTVShows:
            "/3/trending/tv/day"
        case .nowPlaying:
            "/3/movie/now_playing"
        case .upcoming:
            "/3/movie/upcoming"
        }
    }

    func queryItems() -> [URLQueryItem]? {
        switch self {
        case .movieDetails:
            [.init(name: "append_to_response", value: "videos,credits")]
        case .tvShowDetails, .trendingMovies, .trendingTVShows, .nowPlaying:
            nil
        case let .upcoming(page):
            [makePaginationParam(page: page)]
        case .personDetails:
            [.init(name: "append_to_response", value: "combined_credits")]
        }
    }
}
