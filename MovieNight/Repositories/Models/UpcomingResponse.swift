//
//  UpcomingResponse.swift
//  MovieNight
//
//  Created by Boone on 7/14/24.
//

import Foundation

struct UpcomingResponse: Decodable {
    let dates: Dates
    let page: Int
    let results: [Movie]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results, dates
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }

    struct Dates: Decodable {
        let maximum: String
        let minimum: String
    }

    struct Movie: Decodable, Identifiable {
        let id: Int64
        let adult: Bool?
        let backdropPath: String?
        let genreIDs: [Int]
        let originalLanguage, originalTitle, overview: String
        let popularity: Double
        let posterPath: String?
        let releaseDate, title: String
        let video: Bool
        let voteAverage: Double
        let voteCount: Int64

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
        }
    }
}
