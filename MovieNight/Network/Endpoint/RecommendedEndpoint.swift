//
//  RecommendedEndpoint.swift
//  MovieNight
//
//  Created by Boone on 2/4/24.
//

import Foundation

enum RecommendedEndpoint: EndpointProviding {
    case recommendedMovies(id: Int64, page: Int)
}

extension RecommendedEndpoint {
    func path() -> String {
        switch self {
        case .recommendedMovies(let id, _):
            return "/3/movie/\(id)/recommendations"
        }
    }
    
    func queryItems() -> [URLQueryItem]? {
        switch self {
        case .recommendedMovies(_, let page):
            let queryItems: [URLQueryItem] = [
                .init(name: "language", value: "en-US"),
                makePaginationParam(page: page)
            ]

            return queryItems
        }
    }
}
