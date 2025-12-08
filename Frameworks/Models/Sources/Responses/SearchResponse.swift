//
//  MovieResponseTMDB.swift
//  MovieNight
//
//  Created by Boone on 12/23/23.
//

import UIKit

public struct SearchResponse: Equatable, Decodable {
    public let page: Int
    public let results: [ResponseType]
    public let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

public enum MediaType: String, Codable {
    case movie = "movie"
    case tvShow = "tv"

    public var title: String {
        switch self {
        case .movie:
            "Movie"
        case .tvShow:
            "TV Show"
        }
    }
}

public enum ResponseType: Decodable, Hashable {
    case movie(MovieResponse)
    case tvShow(TVShowResponse)
//    case people(ActorResponse)
    case empty

    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try? container.decode(MediaType?.self, forKey: .mediaType)
        let singleContainer = try decoder.singleValueContainer()


        switch type {
        case .movie:
            let movieResponse = try singleContainer.decode(MovieResponse.self)
            self = movieResponse.isValid() ? .movie(movieResponse) : .empty

        case .tvShow:
            let tvShowResponse = try singleContainer.decode(TVShowResponse.self)
            self = tvShowResponse.isValid() ? .tvShow(tvShowResponse) : .empty

        default:
            self = .empty
        }
    }
}

extension ResponseType: Identifiable, DetailViewRepresentable {
    public var releaseDate: String? {
        ""
    }
    
    public var id: Int64 {
        switch self {
        case .movie(let movieResponse):
            movieResponse.id
        case .tvShow(let tvShowResponse):
            tvShowResponse.id
        case .empty:
            0
        }
    }

    public var posterPath: String? {
        switch self {
        case .movie(let movieResponse):
            movieResponse.posterPath
        case .tvShow(let tVShowResponse):
            tVShowResponse.posterPath
        case .empty:
            nil
        }
    }

    var averageColor: UIColor? {
        switch self {
        case .movie(let movieResponse):
            movieResponse.averageColor
        case .tvShow(let tVShowResponse):
            tVShowResponse.averageColor
        case .empty:
            nil
        }
    }

    public var title: String? {
        switch self {
        case .movie(let movieResponse):
            movieResponse.title ?? "No title"
        case .tvShow(let tVShowResponse):
            tVShowResponse.title ?? "No title"
        case .empty:
            ""
        }
    }

    public var overview: String? {
        switch self {
        case .movie(let movieResponse):
            movieResponse.overview ?? "No summary"
        case .tvShow(let tVShowResponse):
            tVShowResponse.overview ?? "No summary"
        case .empty:
            ""
        }
    }

    public var mediaType: MediaType {
        switch self {
        case .movie:
                .movie
        case .tvShow:
                .tvShow
        case .empty:
                .movie
        }
    }

    public var posterData: Data? {
        switch self {
        case .movie(let movieResponse):
            movieResponse.posterData
        case .tvShow(let tVShowResponse):
            tVShowResponse.posterData
        case .empty:
            nil
        }
    }
}
