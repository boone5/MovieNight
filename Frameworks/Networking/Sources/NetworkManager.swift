//
//  NetworkManager.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import Dependencies
import Foundation
import Logger

public struct NetworkClient {
    public var requestData: (_ endpoint: EndpointProviding) async throws -> Data

    /// Generic request function that fetches and decodes data from a given endpoint.
    /// - Parameters:
    ///   - endpoint: The endpoint conforming to `EndpointProviding`.
    ///   - decoder: The JSON decoder to use for decoding the response. Defaults to `JSONDecoder()`.
    /// - Returns: Decoded object of type `T`.
    public func request<T: Decodable>(_ endpoint: EndpointProviding, decoder: JSONDecoder = JSONDecoder()) async throws -> T {
        do {
            let data = try await requestData(endpoint)
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            @Dependency(\.logger.log) var log
            log(.networking, .error, "Failed to decode response for endpoint: \(endpoint.path()) with error: \(error)")
            throw error
        }
    }
}

extension NetworkClient: DependencyKey {
    public static let liveValue =  Self(
        requestData: { endpoint in
            @Dependency(\.logger.log) var log
            guard let url = try? RequestUtils.createURL(from: endpoint) else { throw APIError.badURL }
            let request = RequestUtils.createRequest(url: url, apiKey: endpoint.apiKey)

            do {
                log(.networking, .info, "🛜 \(url)")
                let (data, res) = try await URLSession.shared.data(for: request)

                guard let res = res as? HTTPURLResponse, res.statusCode == 200 else {
                    throw APIError.networkError(URLError(.badServerResponse))
                }

                return data
            } catch {
                log(.networking, .error, "Network request failed for endpoint: \(endpoint.path()) with error: \(error)")
                throw APIError.networkError(error)
            }
        }
    )
}

public extension DependencyValues {
    var networkClient: NetworkClient {
        get { self[NetworkClient.self] }
        set { self[NetworkClient.self] = newValue }
    }
}

private enum RequestUtils {
    static func createURL(from endpoint: EndpointProviding) throws -> URL {
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

    static func createRequest(url: URL, apiKey: String, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        return request
    }
}
