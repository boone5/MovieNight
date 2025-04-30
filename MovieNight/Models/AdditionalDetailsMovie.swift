//
//  AdditionalDetailsMovie.swift
//  MovieNight
//
//  Created by Boone on 2/8/24.
//

import Foundation

struct AdditionalDetailsMovie: Codable {
    let adult: Bool
    let backdropPath: String?
    let genres: [Genre]
    let id: Int
    let originalLanguage, originalTitle, overview: String
    let popularity: Double
    let posterPath: String?
    let releaseDate: String
    let revenue, runtime: Int
    let status, tagline, title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    // Appended to response
    let videos: VideoResponse
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case revenue, runtime, status, tagline, title, video, videos, overview, popularity, genres, id, adult
    }

    // MARK: - SpokenLanguage
    struct SpokenLanguage: Codable {
        let englishName, iso639_1, name: String

        enum CodingKeys: String, CodingKey {
            case englishName = "english_name"
            case iso639_1 = "iso_639_1"
            case name
        }
    }

    struct VideoResponse: Codable {
        let results: [Video]

        enum VideoError: Error {
            case noVideos
            case noTrailer
        }

        public func trailer() throws(VideoError) -> Video {
            guard !results.isEmpty else { throw .noVideos }

            if let trailer = self.results.first(where: { $0.type == .trailer }) {
                return trailer
            } else {
                throw .noTrailer
            }
        }

        struct Video: Codable {
            let iso_639_1: String?
            let iso_3166_1: String?
            let name: String?
            let key: String?
            let site: String?
            let size: Int?
            var type: `Type`?
            let official: Bool
            let publishedAt: String
            let id: String

            enum CodingKeys: String, CodingKey {
                case iso_639_1, iso_3166_1, name, key, site, size, type, official, id
                case publishedAt = "published_at"
            }

            enum `Type`: String, Codable, CaseIterable {
                case featurette = "Featurette"
                case teaser = "Teaser"
                case clip = "Clip"
                case behindTheScense = "Behind the Scenes"
                case trailer = "Trailer"
            }

            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                self.iso_639_1 = try container.decodeIfPresent(String.self, forKey: .iso_639_1)
                self.iso_3166_1 = try container.decodeIfPresent(String.self, forKey: .iso_3166_1)
                self.name = try container.decodeIfPresent(String.self, forKey: .name)
                self.key = try container.decodeIfPresent(String.self, forKey: .key)
                self.site = try container.decodeIfPresent(String.self, forKey: .site)
                self.size = try container.decodeIfPresent(Int.self, forKey: .size)
                self.official = try container.decode(Bool.self, forKey: .official)
                self.publishedAt = try container.decode(String.self, forKey: .publishedAt)
                self.id = try container.decode(String.self, forKey: .id)

                if let type = try? container.decodeIfPresent(`Type`.self, forKey: .type) {
                    self.type = type
                } else {
                    self.type = nil
                }
            }
        }

        // NOTE: Not using from API
        //    let belongsToCollection: MovieCollection?
        //    let spokenLanguages: [SpokenLanguage]
        //    let imdbID: String?

        //    struct MovieCollection: Codable {
        //        let id: Int
        //        let name: String
        //        let posterPath: String?
        //        let backdropPath: String?
        //
        //        enum CodingKeys: String, CodingKey {
        //            case id
        //            case name
        //            case posterPath = "poster_path"
        //            case backdropPath = "backdrop_path"
        //        }
        //    }
    }
}
