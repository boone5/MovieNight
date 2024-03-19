//
//  MovieResponseTMDB.swift
//  MovieNight
//
//  Created by Boone on 12/23/23.
//

import Foundation

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

enum ResponseType: Decodable, Hashable {    
    case movie(MovieResponse)
    case tvShow(TVShowResponse)
    case people(ActorResponse)

    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .mediaType)
        let singleContainer = try decoder.singleValueContainer()

        switch type {
        case "movie":
            self = .movie(try singleContainer.decode(MovieResponse.self))
        case "tv":
            self = .tvShow(try singleContainer.decode(TVShowResponse.self))
        case "person":
            self = .people(try singleContainer.decode(ActorResponse.self))
        default:
            throw DecodingError.valueNotFound(Self.self, .init(codingPath: [], debugDescription: "⛔️ Type: \(type) NOT found!"))
        }
    }
}

extension ResponseType: Identifiable {
    var id: String {
        UUID().uuidString
    }
}
