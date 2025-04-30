//
//  TMDBEndpoint.swift
//  MovieNight
//
//  Created by Boone on 2/8/24.
//

import Foundation

enum TMDBEndpoint: EndpointProviding {
    case movieDetails(id: Int64, hasTrailer: Bool)
    case tvShowDetails(id: Int64)
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
        case .movieDetails(let id, _):
            "/3/movie/\(id)"
        case .tvShowDetails(let id):
            "/3/tv/\(id)"
        }
    }

    func queryItems() -> [URLQueryItem]? {
        switch self {
        case .movieDetails(let id, let hasTrailer):
            [.init(name: "append_to_response", value: "videos,images")]
        case .tvShowDetails:
            nil
        }
    }
}
