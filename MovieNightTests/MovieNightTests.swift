//
//  MovieNightTests.swift
//  MovieNightTests
//
//  Created by Boone on 8/12/23.
//

import XCTest
@testable import MovieNight

final class MovieNightTests: XCTestCase {

    func testDecodeResponse() throws {
        let jsonString = """
        {
          "page": 1,
          "next": "/titles/search/title/Harry%20Potter?exact=false&titleType=movie&page=2",
          "entries": 10,
          "results": [
            {
              "_id": "61e5cdf0d735dff3f953cd43",
              "id": "tt16152642",
              "primaryImage": {
                "id": "rm843228929",
                "width": 1500,
                "height": 2222,
                "url": "https://m.media-amazon.com/images/M/MV5BZTg3NWFkN2ItOTdjMi00NDk4LTllMDktNGZiNTUxYmZmMjlmXkEyXkFqcGdeQXVyMjM4NTM5NDY@._V1_.jpg",
                "caption": {
                "plainText": "Darla's Book Club: Discussing the Harry Potter Series (2020)",
                "__typename": "Markdown"
                },
                "__typename": "Image"
              },
              "titleType": {
                "text": "Movie",
                "id": "movie",
                "isSeries": false,
                "isEpisode": false,
                "__typename": "TitleType"
              },
              "titleText": {
                "text": "Uncorked",
                "__typename": "TitleText"
              },
              "originalTitleText": {
                "text": "Uncorked",
                "__typename": "TitleText"
              },
              "releaseYear": {
                "year": 2021,
                "endYear": null,
                "__typename": "YearRange"
              },
              "releaseDate": {
                "day": 1,
                "month": 1,
                "year": 2021,
                "__typename": "ReleaseDate"
              }
            }
          ]
        }
        """

        let movie = try JSONDecoder().decode(Results.self, from: jsonString.data(using: .utf8)!)

        XCTAssertEqual(movie.results?[0]?._id, "61e5cdf0d735dff3f953cd43")
        XCTAssertEqual(movie.results?[0]?.id, "tt16152642")
        XCTAssertEqual(movie.results?[0]?.primaryImage?.url, "https://m.media-amazon.com/images/M/MV5BZTg3NWFkN2ItOTdjMi00NDk4LTllMDktNGZiNTUxYmZmMjlmXkEyXkFqcGdeQXVyMjM4NTM5NDY@._V1_.jpg")
        XCTAssertEqual(movie.results?[0]?.primaryImage?.height, 2222)
        XCTAssertEqual(movie.results?[0]?.primaryImage?.width, 1500)
        XCTAssertEqual(movie.results?[0]?.titleText?.text, "Uncorked")
    }

}
