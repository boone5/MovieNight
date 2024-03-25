//
//  MovieResponse.swift
//  MovieNight
//
//  Created by Boone on 3/14/24.
//

import Foundation

struct MovieResponse: DetailViewRepresentable, Codable, Hashable, Identifiable {
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
    let mediaType: String
    
    // Additional Properties
    var posterData: Data?
    var userRating: Int16 = 0

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
        case mediaType = "media_type"
    }
}

extension MovieResponse {
    static let mockedData = MovieResponse(
        id: Int64(0),
        adult: false,
        backdropPath: nil,
        genreIDs: [],
        originalLanguage: "en-US",
        originalTitle: "Mocked Title",
        overview: "Lorem ipsum dolor sit amet, consect adipisc elit, sed do eiusmod tempor incidid ut labore et dolore magna. Ut enim ad minim veniam, quis",
        popularity: 234098,
        posterPath: nil,
        releaseDate: "2014-11-01",
        title: "Mocked Title",
        video: false,
        voteAverage: 9.5,
        voteCount: Int64(192837),
        mediaType: "Mocked Media Type",
        userRating: 1
    )
}
