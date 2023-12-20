//
//  APIEndpoint.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import Foundation

enum APIEndpoint {
    case movies(_ title: String)
    // can remove once I know we don't need ThumbnailViewModel
    case fetchMovieThumbnail(_ url: String)
}

extension APIEndpoint {
    var path: String {
        switch self {
        case .movies(let title):
            return "/titles/search/title/\(title)"

        case .fetchMovieThumbnail(let url):
            return url
        }
    }

    var scheme: String {
        "https"
    }

    var host: String {
        "moviesdatabase.p.rapidapi.com"
    }

    var queryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "exact", value: "false"),
            URLQueryItem(name: "titleType", value: "movie")
        ]
    }

    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems

        return urlComponents.url
    }
}
