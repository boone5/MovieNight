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

    struct Details: DetailViewRepresentable, Codable, Hashable, Identifiable {
        let id: Int64
        let adult: Bool
        let backdropPath: String?
        let genreIDs: [Int]
        let originalLanguage, originalTitle, overview: String
        let popularity: Double
        let posterPath: String?
        let releaseDate, title: String
        let video: Bool
        let voteAverage: Double
        let voteCount: Int64

        // Additional Properties
        var posterData: Data?
        var userRating: Int16 = 0
        let mediaType: String? = nil

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

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<MovieResponseTMDB.Details.CodingKeys> = try decoder.container(keyedBy: MovieResponseTMDB.Details.CodingKeys.self)

            self.adult = try container.decode(Bool.self, forKey: .adult)
            self.backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
            self.genreIDs = try container.decode([Int].self, forKey: .genreIDs)
            self.id = try container.decode(Int64.self, forKey: .id)
            self.originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
            self.originalTitle = try container.decode(String.self, forKey: .originalTitle)
            self.overview = try container.decode(String.self, forKey: .overview)
            self.popularity = try container.decode(Double.self, forKey: .popularity)
            self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
            self.releaseDate = try container.decode(String.self, forKey: .releaseDate)
            self.title = try container.decode(String.self, forKey: .title)
            self.video = try container.decode(Bool.self, forKey: .video)
            self.voteCount = try container.decode(Int64.self, forKey: .voteCount)
            self.voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        }

        init(
            id: Int64 = Int64(0),
            adult: Bool = false,
            backdropPath: String? = nil,
            genreIDs: [Int] = [],
            originalLanguage: String = "en-US",
            originalTitle: String = "Mocked Title",
            overview: String = "Lorem ipsum dolor sit amet, consect adipisc elit, sed do eiusmod tempor incidid ut labore et dolore magna. Ut enim ad minim veniam, quis",
            popularity: Double = 234098,
            posterPath: String? = nil,
            releaseDate: String = "2014-11-01",
            title: String = "Mocked Title",
            video: Bool = false,
            voteAverage: Double = 9.5,
            voteCount: Int64 = Int64(192837)
        ) {
            self.id = id
            self.adult = adult
            self.backdropPath = backdropPath
            self.genreIDs = genreIDs
            self.originalLanguage = originalLanguage
            self.originalTitle = originalTitle
            self.overview = overview
            self.popularity = popularity
            self.posterPath = posterPath
            self.releaseDate = releaseDate
            self.title = title
            self.video = video
            self.voteAverage = voteAverage
            self.voteCount = voteCount
            self.userRating = 0
        }
    }
}

extension MovieResponseTMDB.Details {
    static let mockedData: MovieResponseTMDB.Details =
        MovieResponseTMDB.Details()
}
