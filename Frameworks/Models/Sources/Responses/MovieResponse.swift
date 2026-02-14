//
//  MovieResponse.swift
//  MovieNight
//
//  Created by Boone on 3/14/24.
//

import UIKit

public struct MovieResponse: Codable, Hashable, Identifiable {
    public let id: Int64
    let adult: Bool?
    let backdropPath: String?
    let genreIDs: [Int]?
    public let originalLanguage: String?
    public let originalTitle: String?
    public let overview: String?
    let popularity: Double?
    public let posterPath: String?
    public let releaseDate: String?
    public let title: String
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int64?

    // MARK: - App-enriched (NOT decoded)
    public var rating: Int16 = 0
    public var averageColor: UIColor?
    public var comment: String?

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDs = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

extension MovieResponse {
    public init() {
        self.id = 0
        self.title = "Mocked Title"
        self.overview = "Lorem ipsum dolor sit amet, consect adipisc elit, sed do eiusmod tempor incidid ut labore et dolore magna. Ut enim ad minim veniam, quis"
        self.rating = 0
        self.posterPath = nil
        self.genreIDs = []
        self.originalTitle = ""
        self.originalLanguage = ""
        self.popularity = 0
        self.releaseDate = ""
        self.video = false
        self.voteAverage = 0
        self.voteCount = 0
        self.adult = nil
        self.backdropPath = nil
    }
}

// MARK: Mocked Data

//extension MovieResponse {
//    static let mockedData = MovieResponse(
//        id: Int64(0),
//        adult: false,
//        backdropPath: nil,
//        genreIDs: [],
//        originalLanguage: "en-US",
//        originalTitle: "Mocked Title",
//        overview: "Lorem ipsum dolor sit amet, consect adipisc elit, sed do eiusmod tempor incidid ut labore et dolore magna. Ut enim ad minim veniam, quis",
//        popularity: 234098,
//        posterPath: nil,
//        releaseDate: "2014-11-01",
//        title: "Mocked Title",
//        video: false,
//        voteAverage: 9.5,
//        voteCount: Int64(192837),
//        mediaType: "Mocked Media Type",
//        userRating: 1
//    )
//}
