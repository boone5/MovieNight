//
//  MovieResponseTMDB.swift
//  MovieNight
//
//  Created by Boone on 12/23/23.
//

import UIKit

struct SearchResponse: Decodable {
    let page: Int
    let results: [ResponseType]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

enum MediaType: String, Decodable {
    case movie = "movie"
    case tvShow = "tv"

    var title: String {
        switch self {
        case .movie:
            "Movie"
        case .tvShow:
            "TV Show"
        }
    }
}

enum ResponseType: Decodable, Hashable {    
    case movie(MovieResponse)
    case tvShow(TVShowResponse)
//    case people(ActorResponse)
    case empty

    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
    }

    init(from decoder: Decoder) throws {
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

    init(movieData: MovieData) {
        self = .movie(MovieResponse(movieData: movieData))
    }
}

extension ResponseType: Identifiable, DetailViewRepresentable {
    var releaseDate: String? {
        ""
    }
    
    var id: Int64 {
        switch self {
        case .movie(let movieResponse):
            movieResponse.id
        case .tvShow(let tvShowResponse):
            tvShowResponse.id
        case .empty:
            0
        }
    }

    var posterPath: String? {
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

    var title: String? {
        switch self {
        case .movie(let movieResponse):
            movieResponse.title ?? "No title"
        case .tvShow(let tVShowResponse):
            tVShowResponse.title ?? "No title"
        case .empty:
            ""
        }
    }

    var overview: String? {
        switch self {
        case .movie(let movieResponse):
            movieResponse.overview ?? "No summary"
        case .tvShow(let tVShowResponse):
            tVShowResponse.overview ?? "No summary"
        case .empty:
            ""
        }
    }

    var mediaType: MediaType {
        switch self {
        case .movie:
                .movie
        case .tvShow:
                .tvShow
        case .empty:
                .movie
        }
    }

    var posterData: Data? {
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
