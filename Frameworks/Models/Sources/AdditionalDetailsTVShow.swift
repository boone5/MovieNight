//
//  AdditionalDetailsTVShow.swift
//  MovieNight
//
//  Created by Boone on 3/24/24.
//

import Foundation

// MARK: - AdditionalDetailsTVShow
public struct AdditionalDetailsTVShow: Codable {
    public let adult: Bool
    public let backdropPath: String?
    public let createdBy: [CreatedBy]
    public let genres: [Genre]
    public let id: Int
    public let inProduction: Bool
    public let languages: [String]
    public let title: String
    public let networks: [Network]
    public let numberOfEpisodes, numberOfSeasons: Int
    public let originCountry: [String]
    public let originalLanguage, originalTitle, overview: String
    public let popularity: Double
    public let posterPath: String?
    public let seasons: [SeasonResponse]?
    public let firstAirDate: String

    public let status, tagline: String
    public let voteAverage: Double
    public let voteCount: Int

    public let credits: CreditsResponse?

    // Not using from API
    //    let episodeRunTime: [Int]
    //    let lastAirDate: String
    //    let lastEpisodeToAir: Episode
    //    let nextEpisodeToAir: Episode?
    //    let spokenLanguages: [SpokenLanguage]

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case credits
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
    public struct CreatedBy: Codable {
        public let id: Int
        public let creditID, name: String
        public let gender: Int
        public let profilePath: String?

        enum CodingKeys: String, CodingKey {
            case id
            case creditID = "credit_id"
            case name, gender
            case profilePath = "profile_path"
        }
    }

    // MARK: - LastEpisodeToAir
    struct Episode: Codable {
        public let id: Int
        public let name, overview: String
        public let voteAverage: Double
        public let voteCount: Int
        public let airDate: String?
        public let episodeNumber: Int
        public let episodeType, productionCode: String
        public let runtime: Double?
        public let seasonNumber, showID: Int
        public let stillPath: String?

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
    public struct Network: Codable {
        public let id: Int
        public let logoPath, name, originCountry: String

        enum CodingKeys: String, CodingKey {
            case id
            case logoPath = "logo_path"
            case name
            case originCountry = "origin_country"
        }
    }

    // MARK: - Season
    public struct SeasonResponse: Codable, Identifiable {
        public let airDate: String?
        public let episodeCount, id: Int
        public let name, overview: String
        public let posterPath: String?
        public let number: Int
        public let voteAverage: Double

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
