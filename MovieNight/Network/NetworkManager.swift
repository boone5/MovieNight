//
//  NetworkManager.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import Foundation
import Combine

final public class NetworkManager {
    let headers_TMDB = [
      "accept": "application/json",
      "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyYjVkNzgxYjVmNjYwNjU3N2YxMzc2OTlhMGQxNDExYyIsInN1YiI6IjY1ODc1Y2ZkMjJlNDgwN2YwZWMxMjBkZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.x3vnp3acI4iTAPDAG8zvpv11NQlvnERpoSM936AYLO4"
    ]

    public func request(_ endpoint: EndpointProviding) async throws -> Data {
        guard let url = try? createURL(from: endpoint) else { throw APIError.badURL }

        let req = createRequest(with: url)

        do {
            let (data, res) = try await URLSession.shared.data(for: req)

            guard let res = res as? HTTPURLResponse, res.statusCode == 200 else {
                throw APIError.networkError(URLError(.badServerResponse))
            }

            return data
        } catch {
            throw APIError.networkError(error)
        }
    }

    public func createURL(from endpoint: EndpointProviding) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = endpoint.host()
        urlComponents.path = endpoint.path()
        urlComponents.queryItems = endpoint.queryItems()

        guard let url = urlComponents.url else {
            throw APIError.badURL
        }

        return url
    }

    func createRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers_TMDB

        return request
    }
}
