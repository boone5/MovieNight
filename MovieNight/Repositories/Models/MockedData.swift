//
//  MockedData.swift
//  MovieNight
//
//  Created by Boone on 12/28/23.
//

import Foundation

extension MovieResponseTMDB.Details {
    static let mockedData: MovieResponseTMDB.Details =
        MovieResponseTMDB.Details(
            adult: true,
            backdropPath: nil,
            genreIDs: [],
            id: 0,
            originalLanguage: "en-US",
            originalTitle: "Mock 1",
            overview: "Overview for Mock 1",
            popularity: 100,
            posterPath: nil,
            releaseDate: "Release Data",
            title: "Mock 1",
            video: false,
            voteAverage: 4,
            voteCount: 1000)
}
