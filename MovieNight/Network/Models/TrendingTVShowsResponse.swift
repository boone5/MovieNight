//
//  TrendingTVShowsResponse.swift
//  MovieNight
//
//  Created by Boone on 7/29/25.
//

struct TrendingTVShowsResponse: Codable {
    let page: Int
    let results: [TVShowResponse]
}
