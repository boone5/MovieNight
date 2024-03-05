//
//  DetailsEndpoint.swift
//  MovieNight
//
//  Created by Boone on 2/8/24.
//

import Foundation

enum DetailsEndpoint: EndpointProviding {
    case movieDetails(id: Int64)
}

extension DetailsEndpoint {
    func path() -> String {
        switch self {
        case .movieDetails(let id):
            "/3/movie/\(id)"
        }
    }

    func queryItems() -> [URLQueryItem]? {
        return nil
    }
}
