//
//  EndpointProviding.swift
//  MovieNight
//
//  Created by Boone on 12/21/23.
//

import Foundation

public protocol EndpointProviding {
    func host() -> String
    func path() -> String
    func queryItems() -> [URLQueryItem]?
}

extension EndpointProviding {
    public func host() -> String {
        "api.themoviedb.org"
    }

    func makePaginationParam(page: Int) -> URLQueryItem {
        return .init(name: "page", value: String(page))
    }
}
