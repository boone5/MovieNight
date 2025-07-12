//
//  AdditionalDetailsTVShow.swift
//  MovieNight
//
//  Created by Boone on 3/24/24.
//

import Foundation

// MARK: - AdditionalDetailsTVShow
public struct AdditionalDetailsTVShow: Codable {
    let adult: Bool
    let backdropPath: String?
    let createdBy: [CreatedBy]
    let genres: [Genre]
    let id: Int
    let inProduction: Bool
    let languages: [String]
    let title: String
    let networks: [Network]
    let numberOfEpisodes, numberOfSeasons: Int
    let originCountry: [String]
    let originalLanguage, originalTitle, overview: String
    let popularity: Double
    let posterPath: String?
    let seasons: [SeasonResponse]?
    let firstAirDate: String

    let status, tagline: String
    let voteAverage: Double
    let voteCount: Int

    // Not using from API
    //    let episodeRunTime: [Int]
    //    let lastAirDate: String
    //    let lastEpisodeToAir: Episode
    //    let nextEpisodeToAir: Episode?
    //    let spokenLanguages: [SpokenLanguage]

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case createdBy = "created_by"
        case firstAirDate = "first_air_date"
        case genres, id
        case inProduction = "in_production"
        case languages
        case title = "name"
        case networks
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalTitle = "original_name"
        case overview, popularity
        case posterPath = "poster_path"
        case seasons
        case status, tagline
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

    // MARK: - CreatedBy
    struct CreatedBy: Codable {
        let id: Int
        let creditID, name: String
        let gender: Int
        let profilePath: String?

        enum CodingKeys: String, CodingKey {
            case id
            case creditID = "credit_id"
            case name, gender
            case profilePath = "profile_path"
        }
    }

    // MARK: - LastEpisodeToAir
    struct Episode: Codable {
        let id: Int
        let name, overview: String
        let voteAverage: Double
        let voteCount: Int
        let airDate: String?
        let episodeNumber: Int
        let episodeType, productionCode: String
        let runtime: Double?
        let seasonNumber, showID: Int
        let stillPath: String?

        enum CodingKeys: String, CodingKey {
            case id, name, overview
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
            case airDate = "air_date"
            case episodeNumber = "episode_number"
            case episodeType = "episode_type"
            case productionCode = "production_code"
            case runtime
            case seasonNumber = "season_number"
            case showID = "show_id"
            case stillPath = "still_path"
        }
    }

    // MARK: - Network
    struct Network: Codable {
        let id: Int
        let logoPath, name, originCountry: String

        enum CodingKeys: String, CodingKey {
            case id
            case logoPath = "logo_path"
            case name
            case originCountry = "origin_country"
        }
    }

    // MARK: - Season
    public struct SeasonResponse: Codable {
        let airDate: String?
        let episodeCount, id: Int
        let name, overview: String
        let posterPath: String?
        let number: Int
        let voteAverage: Double

        enum CodingKeys: String, CodingKey {
            case airDate = "air_date"
            case episodeCount = "episode_count"
            case id, name, overview
            case posterPath = "poster_path"
            case number = "season_number"
            case voteAverage = "vote_average"
        }

        public func completed() {
            // Core Data
        }

        public func remove() {
            // Core Data
        }
    }
}

extension AdditionalDetailsTVShow {
    public func releasedSeasons() -> [Self.SeasonResponse] {
        guard let seasons else { return [] }
        return seasons.filter { $0.episodeCount > 1 && $0.number != 0 }
    }
}
