//
//  MovieModel.swift
//  MovieNight
//
//  Created by Boone on 8/15/23.
//

import Foundation

struct MovieResponse: Codable {
    let page: Int?
    let next: String?
    let entries: Int?
    // mutable for generating mock data
    var results: [MovieResult]
}

struct MovieResult: Codable, Hashable {
    let _id: String?
    let id: String?
    let uuid: UUID?
    let thumbnail: Thumbail?
    let releaseDate: ReleaseDate?
    let releaseYear: ReleaseYear?
    let titleText: TitleText?
    let titleDetails: TitleDetails?

    enum CodingKeys: String, CodingKey {
        case _id
        case id
        case uuid
        case thumbnail = "primaryImage"
        case releaseDate
        case releaseYear
        case titleText
        case titleDetails = "titleType"
    }

    init(
        _id: String? = nil,
        id: String? = nil,
        uuid: UUID? = UUID(),
        thumbnail: Thumbail? = nil,
        releaseDate: ReleaseDate? = nil,
        releaseYear: ReleaseYear? = nil,
        titleText: TitleText? = nil,
        titleDetails: TitleDetails? = nil) {
            self._id = _id
            self.id = id
            self.uuid = uuid
            self.thumbnail = thumbnail
            self.releaseDate = releaseDate
            self.releaseYear = releaseYear
            self.titleText = titleText
            self.titleDetails = titleDetails
    }

    struct TitleText: Codable, Hashable {
        let text: String?
    }

    struct Thumbail: Codable, Hashable {
        let id: String?
        let height: Int?
        let width: Int?
        let url: String?
        var imgData: Data? // to be set from Network Response

        init(id: String? = nil, height: Int? = nil, width: Int? = nil, url: String? = nil, imgData: Data? = nil) {
            self.id = id
            self.height = height
            self.width = width
            self.url = url
            self.imgData = imgData
        }
    }

    struct ReleaseDate: Codable, Hashable {
        let day: Int?
        let month: Int?
        let year: Int?
    }

    struct ReleaseYear: Codable, Hashable {
        let endYear: String?
        let year: Int?
    }

    struct TitleDetails: Codable, Hashable {
        let id: String?
        let isEpisode: Bool?
        let isSeries: Bool?
        let text: String?
    }
}

class MovieMocks {
    var movies: MovieResponse = MovieResponse(page: 0, next: "next", entries: 10, results: [])

    func generateMovies(count: Int) -> MovieResponse {
        for i in 0..<count {
            let movie = MovieResult(
                _id: "mock\(i)",
                id: "mock\(i)",
                thumbnail: MovieResult.Thumbail(id: "mock\(i)", height: nil, width: nil, url: "https://m.media-amazon.com/images/M/MV5BZTg3NWFkN2ItOTdjMi00NDk4LTllMDktNGZiNTUxYmZmMjlmXkEyXkFqcGdeQXVyMjM4NTM5NDY@._V1_.jpg"),
                releaseDate: nil,
                releaseYear: MovieResult.ReleaseYear(endYear: nil, year: 2023),
                titleText: MovieResult.TitleText(text: "Movie \(i)"),
                titleDetails: MovieResult.TitleDetails(id: "movie", isEpisode: false, isSeries: false, text: "movie"))

            self.movies.results.append(movie)
        }
        return movies
    }
}
