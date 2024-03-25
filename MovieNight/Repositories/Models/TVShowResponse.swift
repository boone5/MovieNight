//
//  TVShowResponse.swift
//  MovieNight
//
//  Created by Boone on 3/14/24.
//

struct TVShowResponse: Codable, Hashable, Identifiable {
    let id: Int64
    let adult: Bool?
    let backdropPath: String?
    let posterPath: String?
    let title: String
    let originalTitle: String
    let originalLanguage: String
    let overview: String
    let mediaType: String
    let genreIds: [Int]
    let popularity: Double
    let firstAirDate: String
    let voteAverage: Double
    let voteCount: Int
    let originCountry: [String]

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
