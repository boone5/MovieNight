//
//  TrendingTVShowsResponse.swift
//  MovieNight
//
//  Created by Boone on 7/29/25.
//

public struct TrendingTVShowsResponse: Codable, Equatable {
    public let page: Int
    public let results: [MediaResult]
}
