//
//  APIError.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import Foundation.NSURLError

public enum APIError: Error, Equatable {
    case networkUnavailable
    case unknownError(Error)
    case decodingError(Error)
    case badURL
    case networkError(Error)

    public var description: String {
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

    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.networkUnavailable, .networkUnavailable): true
        case (.badURL, .badURL): true
        case (.unknownError, .unknownError): true
        case (.decodingError, .decodingError): true
        case (.networkError, .networkError): true
        default: false
        }
    }
}
