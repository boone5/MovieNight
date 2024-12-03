//
//  NetworkManager.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import Foundation
import Combine

final public class NetworkManager {
    public func request<T: Decodable>(_ endpoint: EndpointProviding) async throws -> T {
        guard let url = try? createURL(from: endpoint) else { throw APIError.badURL }
        let request = createRequest(url: url, apiKey: endpoint.apiKey)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        print("making network request")

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    public func requestData(_ endpoint: EndpointProviding) async throws -> Data {
        guard let url = try? createURL(from: endpoint) else { throw APIError.badURL }
        let request = createRequest(url: url, apiKey: endpoint.apiKey)

        do {
            let (data, res) = try await URLSession.shared.data(for: request)

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

    private func createRequest(url: URL, apiKey: String, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        return request
    }
}
