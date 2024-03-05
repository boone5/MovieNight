//
//  CastEndpoint.swift
//  MovieNight
//
//  Created by Boone on 2/7/24.
//

import Foundation

enum CastEndpoint: EndpointProviding {
    case movieCredits(id: Int64)

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
