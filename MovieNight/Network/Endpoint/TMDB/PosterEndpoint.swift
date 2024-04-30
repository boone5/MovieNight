//
//  PosterEndpoint.swift
//  MovieNight
//
//  Created by Boone on 12/26/23.
//

import Foundation

// example endpoint:
// https://image.tmdb.org/t/p/w342/qpJyTxR33KG9qFmXoCD5AUTToPl.jpg

enum PosterEndpoint: EndpointProviding {
    case poster(_ extension: String)
}

extension PosterEndpoint {
    var apiKey: String {
        APIKey.authorization_TMDB
    }

    func host() -> String {
        return "image.tmdb.org" // might not want to hardcode this
    }

    func path() -> String {
        switch self {
        case .poster(let ext):
            return "/t/p/w500" + ext // might not want to hardcode this
        }
    }

    func queryItems() -> [URLQueryItem]? {
        return nil
    }
}
