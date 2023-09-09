//
//  NetworkManager.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import Foundation

class NetworkManager {
    let headers = [
        "X-RapidAPI-Key": "23a15db573mshe9f036d0688007bp1d8ea0jsn4c70d99f389b",
        "X-RapidAPI-Host": "moviesdatabase.p.rapidapi.com"
    ]

    func request(_ endpoint: APIEndpoint) async throws -> Data {
        guard let url = URL(string: endpoint.path) else {
            throw APIError.badURL
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

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
}
