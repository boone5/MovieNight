//
//  MovieModel.swift
//  MovieNight
//
//  Created by Boone on 8/15/23.
//

struct MovieResponse: Codable {
    let page: Int?
    let next: String?
    let entries: Int?
    // mutable for generating mock data
    var results: [Movie?]
}

struct Movie: Codable {    
    let _id: String?
    let id: String?
    let thumbnail: Thumbail?
    let releaseDate: ReleaseDate?
    let releaseYear: ReleaseYear?
    let titleText: TitleText?
    let titleDetails: TitleDetails?

    enum CodingKeys: String, CodingKey {
        case _id
        case id
        case thumbnail = "primaryImage"
        case releaseDate
        case releaseYear
        case titleText
        case titleDetails = "titleType"
    }
}

struct TitleText: Codable {
    let text: String?
}

struct Thumbail: Codable {
    let id: String?
    let height: Int?
    let width: Int?
    let url: String?
}

struct ReleaseDate: Codable {
    let day: Int?
    let month: Int?
    let year: Int?
}

struct ReleaseYear: Codable {
    let endYear: String?
    let year: Int?
}

struct TitleDetails: Codable {
    let id: String?
    let isEpisode: Bool?
    let isSeries: Bool?
    let text: String?
}

class MovieMocks {
    var movies: MovieResponse = MovieResponse(page: 0, next: "next", entries: 10, results: [])

    func generateMovies(count: Int) -> MovieResponse {
        for i in 0..<count {
            let movie = Movie(
                _id: "mock\(i)",
                id: "mock\(i)",
                thumbnail: nil,
                releaseDate: nil,
                releaseYear: nil,
                titleText: TitleText(text: "Movie \(i)"),
                titleDetails: TitleDetails(id: "movie", isEpisode: false, isSeries: false, text: "movie"))

            self.movies.results.append(movie)
        }
        return movies
    }
}
