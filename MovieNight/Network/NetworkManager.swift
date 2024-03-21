//
//  NetworkManager.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import Foundation
import Combine

final public class NetworkManager {
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

    private func createURL(from endpoint: EndpointProviding) throws -> URL {
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

    private func createRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = APIKey.headers_TMDB

        return request
    }
}
