//
//  MovieResponseTMDB.swift
//  MovieNight
//
//  Created by Boone on 12/23/23.
//

import Foundation

struct MovieResponseTMDB: Codable {
    let page: Int
    let results: [Details]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }

    struct Details: Codable, Hashable, Identifiable {
        let id: Int
        let adult: Bool
        let backdropPath: String?
        let genreIDs: [Int]
        let originalLanguage, originalTitle, overview: String
        let popularity: Double
        let posterPath: String?
        let releaseDate, title: String
        let video: Bool
        let voteAverage: Double
        let voteCount: Int16

        var posterData: Data?

        enum CodingKeys: String, CodingKey {
            case adult
            case backdropPath = "backdrop_path"
            case genreIDs = "genre_ids"
            case id
            case originalLanguage = "original_language"
            case originalTitle = "original_title"
            case overview, popularity
            case posterPath = "poster_path"
            case releaseDate = "release_date"
            case title, video
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
            case posterData
        }
    }
}

extension MovieResponseTMDB.Details {
    var _id: Int64 {
        Int64(self.id)
    }
}
