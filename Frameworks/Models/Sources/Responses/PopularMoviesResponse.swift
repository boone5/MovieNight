//
//  PopularMoviesResponse.swift
//  MovieNight
//
//  Created by Boone on 7/29/25.
//

public struct TrendingMoviesResponse: Codable {
    public let page: Int
    public let results: [MovieResponse]
}
