//
//  LoginEndpoint.swift
//  MovieNight
//
//  Created by Boone on 4/20/24.
//

import Foundation

public enum LoginEndpoint: EndpointProviding {
    case login
    case register
}

public extension LoginEndpoint {
    func host() -> String {
        "ezojrg1lse.execute-api.us-east-2.amazonaws.com"
    }

    func path() -> String {
        switch self {
        case .login:
            "/prod/login"
        case .register:
            "/prod/register"
        }

    }

    func queryItems() -> [URLQueryItem]? {
        nil
    }

    var apiKey: String {
        APIKey.key_AWS
    }
}
