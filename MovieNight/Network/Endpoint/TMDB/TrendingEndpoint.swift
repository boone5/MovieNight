//
//  TrendingEndpoint.swift
//  MovieNight
//
//  Created by Boone on 7/14/24.
//

import Foundation

enum TrendingEndpoint: EndpointProviding {
    case movies
    case tvShow
}

extension TrendingEndpoint {
    public var apiKey: String {
        APIKey.authorization_TMDB
    }

    func host() -> String {
        "api.themoviedb.org"
    }

    func path() -> String {
        switch self {
        case .movies:
            "/3/trending/movie/week"
        case .tvShow:
            "/3/trending/tv/week"
        }

    }

    func queryItems() -> [URLQueryItem]? {
        let queryItems: [URLQueryItem] = [
            .init(name: "language", value: "en-US")
        ]

        return queryItems
    }
}
