//
//  TVShowResponse.swift
//  MovieNight
//
//  Created by Boone on 3/14/24.
//

import UIKit

public struct TVShowResponse: Codable, Hashable, Identifiable {
    public var releaseDate: String? {
        firstAirDate
    }

    public let id: Int64
    let adult: Bool?
    let backdropPath: String?
    let genreIDs: [Int]?
    public let originalLanguage: String?
    public let originalTitle: String?
    public let overview: String?
    let popularity: Double?
    public let posterPath: String?
    public let firstAirDate: String?
    public let title: String
    let voteAverage: Double?
    let voteCount: Int64?
    public let mediaType: MediaType
    public let originCountries: [String]?

    // App-enriched
    public var averageColor: UIColor?

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDs = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_name"
        case overview
        case popularity
        case posterPath = "poster_path"
        case firstAirDate = "first_air_date"
        case title = "name"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case mediaType = "media_type"
        case originCountries = "origin_country"
    }
}

extension TVShowResponse {
    public init() {
        self.id = Int64.min
        self.adult = true
        self.backdropPath = ""
        self.posterPath = ""
        self.title = "Mocked Title"
        self.originalTitle = ""
        self.originalLanguage = ""
        self.overview = "Lorem ipsum dolor sit amet, consect adipisc elit, sed do eiusmod tempor incidid ut labore et dolore magna. Ut enim ad minim veniam, quis"
        self.mediaType = .tv
        self.genreIDs = []
        self.popularity = 0.0
        self.firstAirDate = "air date"
        self.voteAverage = 2
        self.voteCount = 3
        self.originCountries = []
    }
}
