//
//  MovieResponseTMDB.swift
//  MovieNight
//
//  Created by Boone on 12/23/23.
//

import UIKit

public struct SearchResponse: Equatable, Decodable {
    public let page: Int
    public let results: [MediaResult]
    public let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

public enum MediaType: String, Codable {
    case movie
    case tv
    case person

    public var title: String {
        switch self {
        case .movie: "Movie"
        case .tv: "Tv"
        case .person: "Person"
        }
    }
}

public enum MediaResult: Codable, Hashable {
    case movie(MovieResponse)
    case tv(TVShowResponse)
    case person(PersonResponse)

    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mediaType = try container.decode(MediaType.self, forKey: .mediaType)

        switch mediaType {
        case .movie:
            self = .movie(try MovieResponse(from: decoder))
        case .tv:
            self = .tv(try TVShowResponse(from: decoder))
        case .person:
            self = .person(try PersonResponse(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .movie(let m):
            try m.encode(to: encoder)
        case .tv(let t):
            try t.encode(to: encoder)
        case .person(let p):
            try p.encode(to: encoder)
        }
    }
}

extension MediaResult: Identifiable, DetailViewRepresentable {
    public var id: Int64 {
        switch self {
        case .movie(let m): m.id
        case .tv(let t): t.id
        case .person(let p): p.id
        }
    }

    public var posterPath: String? {
        switch self {
        case .movie(let m): m.posterPath
        case .tv(let t): t.posterPath
        case .person(let p): p.posterPath
        }
    }

    var averageColor: UIColor? {
        switch self {
        case .movie(let m): m.averageColor
        case .tv(let t): t.averageColor
        case .person: nil
        }
    }

    public var title: String {
        switch self {
        case .movie(let m): m.title
        case .tv(let t): t.title
        case .person(let p): p.title
        }
    }

    public var overview: String? {
        switch self {
        case .movie(let m): m.overview
        case .tv(let t): t.overview
        case .person: nil
        }
    }

    public var mediaType: MediaType {
        switch self {
        case .movie: .movie
        case .tv: .tv
        case .person: .person
        }
    }
}
