//
//  NetworkManager.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import Foundation
import Combine

class NetworkManager {
    static var shared = NetworkManager()

    private let headers = [
        "X-RapidAPI-Key": "23a15db573mshe9f036d0688007bp1d8ea0jsn4c70d99f389b",
        "X-RapidAPI-Host": "moviesdatabase.p.rapidapi.com"
    ]

    private init() { }

    #warning("TODO: Introduce Generics")
    func request(_ endpoint: APIEndpoint) async throws -> Data {
        guard let url = endpoint.url else {
            throw APIError.badURL
        }

        let request = createRequest(url: url)

        do {
            #warning("TODO: Handle response status codes")
            let (data, _) = try await URLSession.shared.data(for: request)

            return data

        } catch {
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                throw APIError.networkUnavailable
            } else {
                throw APIError.unknownError(error)
            }
        }
    }

    func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        return request
    }
}
