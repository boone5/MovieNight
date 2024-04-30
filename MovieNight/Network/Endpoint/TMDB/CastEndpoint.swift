//
//  CastEndpoint.swift
//  MovieNight
//
//  Created by Boone on 2/7/24.
//

import Foundation

enum CastEndpoint: EndpointProviding {
    case movieCredits(id: Int64)
}

extension CastEndpoint {
    var apiKey: String {
        APIKey.authorization_TMDB
    }
    
    public func host() -> String {
        "api.themoviedb.org"
    }

    func path() -> String {
        switch self {
        case .movieCredits(let id):
            return "/3/movie/\(id)/credits"
        }
    }

    func queryItems() -> [URLQueryItem]? {
        return nil
    }
}
