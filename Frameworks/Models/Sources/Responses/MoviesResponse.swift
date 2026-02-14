//
//  MoviesResponse.swift
//  MovieNight
//
//  Created by Boone on 7/29/25.
//

public struct MoviesResponse: Codable, Equatable {
    public let page: Int
    public let results: [MovieResponse]
    public let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
    }

    public init(page: Int = 1, results: [MovieResponse], totalPages: Int = 1) {
        self.page = page
        self.results = results
        self.totalPages = totalPages
    }
}
