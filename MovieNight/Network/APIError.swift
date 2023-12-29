//
//  APIError.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import Foundation.NSURLError

enum APIError: Error {
    case networkUnavailable
    case unknownError(Error)
    case decodingError(Error)
    case badURL
    case networkError(Error)

    var description: String {
        switch self {
        case .networkUnavailable:
            return "😡 No internet connection."
        case .unknownError(let error):
            return "😡 Something went wrong: \(error)"
        case .decodingError(_):
            return "😡 Had trouble decoding: \(self)"
        case .badURL:
            return "😡 Invalid URL"
        case .networkError(let error):
            return "😡 Network error: \(error)"
        }
    }
}
