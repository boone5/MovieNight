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
          "results": [
            {
              "adult": false,
              "backdrop_path": "/cFyp7F8qiBSuSj1qhUnu8MDvubl.jpg",
              "id": 201834,
              "name": "ted",
              "original_language": "en",
              "original_name": "ted",
              "overview": "It's 1993 and Ted the bear's moment of fame has passed, leaving him living with his best friend, 16-year-old John Bennett, who lives in a working-class Boston home with his parents and cousin. Ted may not be the best influence on John, but when it comes right down to it, he's willing to go out on a limb to help his friend and his family.",
              "poster_path": "/cPn71YFDENH0JkWUezlsLyWmLfN.jpg",
              "media_type": "tv",
              "genre_ids": [
                35
              ],
              "popularity": 190.117,
              "first_air_date": "2024-01-11",
              "vote_average": 8.13,
              "vote_count": 284,
              "origin_country": [
                "US"
              ]
            },
            {
              "adult": false,
              "backdrop_path": "/wS9TiAS1WckeTS2IrFg5dRN9WQD.jpg",
              "id": 72105,
              "title": "Ted",
              "original_language": "en",
              "original_title": "Ted",
              "overview": "John Bennett, a man whose childhood wish of bringing his teddy bear to life came true, now must decide between keeping the relationship with the bear or his girlfriend, Lori.",
              "poster_path": "/1QVZXQQHCEIj8lyUhdBYd2qOYtq.jpg",
              "media_type": "movie",
              "genre_ids": [
                35,
                14
              ],
              "popularity": 80.136,
              "release_date": "2012-06-29",
              "video": false,
              "vote_average": 6.421,
              "vote_count": 11870
            },
            {
              "adult": false,
              "backdrop_path": "/8FWC4tDWB1p006vwiubhai4a8iS.jpg",
              "id": 1020969,
              "title": "Teddy's Christmas",
              "original_language": "no",
              "original_title": "Teddybjørnens Jul",
              "overview": "While visiting a Christmas market in her Norwegian town, eight year old Mariann spots a talking teddy bear at a carnival game booth. However, when someone else wins it, she embarks on a quest to find the adorable bear that captured her heart.",
              "poster_path": "/jEf96axaZhZQEu9ORVtEujBTG9p.jpg",
              "media_type": "movie",
              "genre_ids": [
                10751,
                12,
                14
              ],
              "popularity": 34.888,
              "release_date": "2022-11-05",
              "video": false,
              "vote_average": 7.2,
              "vote_count": 40
            },
            {
              "adult": false,
              "backdrop_path": "/9gsZNezV4WcAtv5l3m12K8rLOos.jpg",
              "id": 241514,
              "name": "The Teddy Teclebrhan Show",
              "original_language": "de",
              "original_name": "Die Teddy Teclebrhan Show",
              "overview": "In his new variety show, Teddy presents us with the very best of his world: love, music, comedy, celebrity guests, and creative chaos, which together create a brilliant show performed in front of a live audience with a live band! Antoine, Ernst Riedler, and Percy all have their own particular ideas about how the show works best, even if they are all played by Teddy.",
              "poster_path": "/mvuIZ70qlxGowMXacSSVbJwXaI0.jpg",
              "media_type": "tv",
              "genre_ids": [
                35
              ],
              "popularity": 24.525,
              "first_air_date": "2024-02-20",
              "vote_average": 6,
              "vote_count": 1,
              "origin_country": [
                "DE"
              ]
            },
            {
              "adult": false,
              "id": 3270876,
              "name": "Ted",
              "original_name": "Ted",
              "media_type": "person",
              "popularity": 0.6,
              "gender": 0,
              "known_for_department": "Acting",
              "profile_path": null,
              "known_for": []
            }
          ],
          "total_pages": 1000,
          "total_results": 20000
        }
        """

        let jsonString2 = """
        {
          "page": 1,
          "results": [
            {
              "adult": false,
              "backdrop_path": "/wS9TiAS1WckeTS2IrFg5dRN9WQD.jpg",
              "id": 72105,
              "title": "Ted",
              "original_language": "en",
              "original_title": "Ted",
              "overview": "John Bennett, a man whose childhood wish of bringing his teddy bear to life came true, now must decide between keeping the relationship with the bear or his girlfriend, Lori.",
              "poster_path": "/1QVZXQQHCEIj8lyUhdBYd2qOYtq.jpg",
              "media_type": "movie",
              "genre_ids": [
                35,
                14
              ],
              "popularity": 80.136,
              "release_date": "2012-06-29",
              "video": false,
              "vote_average": 6.421,
              "vote_count": 11870
            }
          ],
          "total_pages": 1000,
          "total_results": 20000
        }
        """

        do {
            let decoder = JSONDecoder()

            let movie = try decoder.decode(SearchResponse.self, from: jsonString.data(using: .utf8)!)

            print("Success!")
            print(movie)
        } catch {
            print(error)
        }

//        XCTAssertEqual(movie.results![0]?._id, "61e5cdf0d735dff3f953cd43")
//        XCTAssertEqual(movie.results![0]?.id, "tt16152642")
//        XCTAssertEqual(movie.results![0]?.thumbnail?.url, "https://m.media-amazon.com/images/M/MV5BZTg3NWFkN2ItOTdjMi00NDk4LTllMDktNGZiNTUxYmZmMjlmXkEyXkFqcGdeQXVyMjM4NTM5NDY@._V1_.jpg")
//        XCTAssertEqual(movie.results![0]?.thumbnail?.height, 2222)
//        XCTAssertEqual(movie.results![0]?.thumbnail?.width, 1500)
//        XCTAssertEqual(movie.results![0]?.titleText?.text, "Uncorked")
    }
}
