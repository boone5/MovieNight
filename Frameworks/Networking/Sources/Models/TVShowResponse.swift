//
//  TVShowResponse.swift
//  MovieNight
//
//  Created by Boone on 3/14/24.
//

import UIKit

public struct TVShowResponse: Codable, Hashable, Identifiable, DetailViewRepresentable {
    public var releaseDate: String? {
        firstAirDate
    }
    
    public let id: Int64
    let adult: Bool?
    let backdropPath: String?
    public let posterPath: String?
    public let title: String?
    let originalTitle: String?
    let originalLanguage: String?
    public let overview: String?
    public let mediaType: MediaType
    let genreIds: [Int]?
    let popularity: Double?
    let firstAirDate: String?
    let voteAverage: Double?
    let voteCount: Int?
    let originCountry: [String]?

    // Additional Properties
    public var posterData: Data?
    var averageColor: UIColor?

    init() {
        self.id = Int64.min
        self.adult = true
        self.backdropPath = ""
        self.posterPath = ""
        self.title = "Mocked Title"
        self.originalTitle = ""
        self.originalLanguage = ""
        self.overview = "Lorem ipsum dolor sit amet, consect adipisc elit, sed do eiusmod tempor incidid ut labore et dolore magna. Ut enim ad minim veniam, quis"
        self.mediaType = .tvShow
        self.genreIds = []
        self.popularity = 0.0
        self.firstAirDate = "air date"
        self.voteAverage = 2
        self.voteCount = 3
        self.originCountry = []
    }

    enum CodingKeys: String, CodingKey {
        case id
        case adult
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case title = "name"
        case originalTitle = "original_name"
        case originalLanguage = "original_language"
        case overview
        case mediaType = "media_type"
        case genreIds = "genre_ids"
        case popularity
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case originCountry = "origin_country"
    }
}

extension TVShowResponse {
    func isValid() -> Bool {
        let hasPoster = self.posterPath != nil

        return hasPoster
    }
}
