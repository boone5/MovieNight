//
//  APIError.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

enum APIError: Error {
    case networkUnavailable
    case invalidFormat
    case unknownError(Error)
    case decodingError(Error)
    case encodingError
    case badURL

    var description: String {
        switch self {
        case .networkUnavailable:
            return "😡 No internet connection."
        case .unknownError(let error):
            return "😡 Something went wrong: \(error)"
        case .decodingError(_), .encodingError, .invalidFormat, .badURL:
            return "😡 Invalid server response: \(self)"
        }
    }
}
