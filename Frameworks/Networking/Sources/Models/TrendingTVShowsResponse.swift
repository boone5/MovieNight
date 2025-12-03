//
//  TrendingTVShowsResponse.swift
//  MovieNight
//
//  Created by Boone on 7/29/25.
//

public struct TrendingTVShowsResponse: Codable {
    public let page: Int
    public let results: [TVShowResponse]
}
