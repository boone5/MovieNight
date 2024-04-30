//
//  LoginEndpoint.swift
//  MovieNight
//
//  Created by Boone on 4/20/24.
//

import Foundation

enum LoginEndpoint: EndpointProviding {
    case login
}

extension LoginEndpoint {
    func host() -> String {
        "ezojrg1lse.execute-api.us-east-2.amazonaws.com"
    }

    func path() -> String {
        "/prod/login"
    }

    func queryItems() -> [URLQueryItem]? {
        nil
    }

    var apiKey: String {
        APIKey.key_AWS
    }
}
