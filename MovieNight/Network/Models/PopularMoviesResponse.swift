//
//  PopularMoviesResponse.swift
//  MovieNight
//
//  Created by Boone on 7/29/25.
//

struct TrendingMoviesResponse: Codable {
    let page: Int
    let results: [MovieResponse]
}
