//
//  NetworkManager.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import Dependencies
import Foundation
import Logger
import Models

public struct NetworkClient {
    /// Generic request function that fetches raw data from a given endpoint.
    ///
    /// Note: This is a low-level function. Prefer using the generic `request` function for most use cases.
    public var requestData: (_ endpoint: EndpointProviding) async throws(APIError) -> Data

    // Deprecate this

    /// Generic request function that fetches and decodes data from a given endpoint.
    /// - Parameters:
    ///   - endpoint: The endpoint conforming to `EndpointProviding`.
    ///   - decoder: The JSON decoder to use for decoding the response. Defaults to `JSONDecoder()`.
    /// - Returns: Decoded object of type `T`.
    public func request<T: Decodable>(_ endpoint: EndpointProviding, decoder: JSONDecoder = JSONDecoder()) async throws -> T {
        try await Self.decode(endpoint, requestData: requestData)
    }

    // MARK: Specific requests

    /// Fetches additional details for a TV show by its ID.
    public var fetchTVShowDetails: (_ id: MediaItem.ID) async throws -> AdditionalDetailsTVShow

    /// Fetches additional details for a movie by its ID.
    public var fetchMovieDetails: (_ id: MediaItem.ID) async throws -> AdditionalDetailsMovie

    /// Fetches additional details for a person by its ID.
    public var fetchPersonDetails: (_ id: MediaItem.ID) async throws -> AdditionalDetailsPerson

    public var fetchTrendingMovies: () async throws -> MoviesResponse
    public var fetchNowPlaying: () async throws -> MoviesResponse
    public var fetchUpcoming: (_ minimumCount: Int) async throws -> MoviesResponse
    public var fetchTrendingTVShows: () async throws -> TrendingTVShowsResponse
}

extension NetworkClient {
    static func decode<T: Decodable>(
        _ endpoint: EndpointProviding,
        requestData: @escaping (_ endpoint: EndpointProviding) async throws -> Data,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws(APIError) -> T {
        do {
            let data = try await requestData(endpoint)
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            @Dependency(\.logger.log) var log
            log(.networking, .error, "Failed to decode response for endpoint: \(endpoint.path()) with error: \(error)")
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}


extension NetworkClient: DependencyKey {
    public static let liveValue: Self = {
        let requestData = RequestUtils.requestData

        return Self(
            requestData: requestData,
            fetchTVShowDetails: { id in
                try await Self.decode(TMDBEndpoint.tvShowDetails(id: id), requestData: requestData)
            },
            fetchMovieDetails: { id in
                try await Self.decode(TMDBEndpoint.movieDetails(id: id), requestData: requestData)
            },
            fetchPersonDetails: { id in
                try await Self.decode(TMDBEndpoint.personDetails(id: id), requestData: requestData)
            },
            fetchTrendingMovies: {
                try await Self.decode(TMDBEndpoint.trendingMovies, requestData: requestData)
            },
            fetchNowPlaying: {
                try await Self.decode(TMDBEndpoint.nowPlaying, requestData: requestData)
            },
            fetchUpcoming: { minimumCount in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let today = formatter.string(from: .now)

                var accumulated: [MovieResponse] = []
                var page = 1

                while accumulated.count < minimumCount {
                    let response: MoviesResponse = try await Self.decode(
                        TMDBEndpoint.upcoming(page: page),
                        requestData: requestData
                    )
                    let future = response.results.filter {
                        guard let releaseDate = $0.releaseDate else { return false }
                        return releaseDate >= today
                    }
                    accumulated.append(contentsOf: future)
                    if page >= response.totalPages { break }
                    page += 1
                }

                return MoviesResponse(results: Array(accumulated.prefix(minimumCount)))
            },
            fetchTrendingTVShows: {
                try await Self.decode(TMDBEndpoint.trendingTVShows, requestData: requestData)
            }
        )
    }()
}

public extension DependencyValues {
    var networkClient: NetworkClient {
        get { self[NetworkClient.self] }
        set { self[NetworkClient.self] = newValue }
    }
}

private enum RequestUtils {
    static func requestData(from endpoint: EndpointProviding) async throws(APIError) -> Data {
        @Dependency(\.logger.log) var log
        guard let url = try? createURL(from: endpoint) else {
            throw APIError.badURL
        }

        let request = createRequest(url: url, apiKey: endpoint.apiKey)

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
