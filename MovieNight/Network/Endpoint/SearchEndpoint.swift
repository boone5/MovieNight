//
//  SearchEndpoint.swift
//  MovieNight
//
//  Created by Boone on 12/21/23.
//

import Foundation

public enum SearchEndpoint: EndpointProviding {
    case search(title: String, page: Int = 1)
    case multi(query: String, page: Int = 1)
}

extension SearchEndpoint {
    public func path() -> String {
        switch self {
        case .search:
            return "/3/search/movie"
        case .multi:
            return "/3/search/multi"
        }
    }

    public func queryItems() -> [URLQueryItem]? {
        switch self {
        case .search(let title, let page):
            let queryItems: [URLQueryItem] = [
                .init(name: "language", value: "en-US"),
                .init(name: "query", value: title),
                makePaginationParam(page: page)
            ]

            return queryItems
        case .multi(query: let query, page: let page):
            let queryItems: [URLQueryItem] = [
                .init(name: "language", value: "en-US"),
                .init(name: "query", value: query),
                makePaginationParam(page: page)
            ]

            return queryItems
        }
    }
}
