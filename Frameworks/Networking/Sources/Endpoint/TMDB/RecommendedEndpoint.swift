//
//  RecommendedEndpoint.swift
//  MovieNight
//
//  Created by Boone on 2/4/24.
//

import Foundation

enum RecommendedEndpoint: EndpointProviding {
    case movies(id: Int64, page: Int)
    case tvShows(id: Int64, page: Int)
}

extension RecommendedEndpoint {
    var apiKey: String {
        APIKey.authorization_TMDB
    }
    
    public func host() -> String {
        "api.themoviedb.org"
    }
    
    func path() -> String {
        switch self {
        case .movies(let id, _):
            return "/3/movie/\(id)/recommendations"
        case .tvShows(let id, _):
            return "/3/tv/\(id)/recommendations"
        }
    }
    
    func queryItems() -> [URLQueryItem]? {
        switch self {
        case .movies(_, let page):
            let queryItems: [URLQueryItem] = [
                .init(name: "language", value: "en-US"),
                makePaginationParam(page: page)
            ]

            return queryItems

        case .tvShows(_, let page):
            let queryItems: [URLQueryItem] = [
                .init(name: "language", value: "en-US"),
                makePaginationParam(page: page)
            ]

            return queryItems
        }
    }
}
