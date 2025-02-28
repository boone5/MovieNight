//
//  UpcomingEndpoint.swift
//  MovieNight
//
//  Created by Boone on 7/14/24.
//

import Foundation

struct UpcomingEndpoint: EndpointProviding {
    public var apiKey: String {
        APIKey.authorization_TMDB
    }

    func host() -> String {
        "api.themoviedb.org"
    }

    func path() -> String {
        "/3/movie/upcoming"
    }

    func queryItems() -> [URLQueryItem]? {
        let queryItems: [URLQueryItem] = [
            .init(name: "language", value: "en-US"),
            .init(name: "region", value: "US"),
            makePaginationParam(page: 1)
        ]

        return queryItems
    }
}
