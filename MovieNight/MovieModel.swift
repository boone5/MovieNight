//
//  MovieModel.swift
//  MovieNight
//
//  Created by Boone on 8/15/23.
//

struct Results: Codable {
    let page: Int?
    let next: String?
    let entries: Int?
    let results: [Movie?]?
}

struct Movie: Codable {
    let _id: String?
    let id: String?
//    let originalTitleText: TitleText?
    let primaryImage: Thumbail?
    let releaseDate: ReleaseDate?
    let releaseYear: YearRange?
    let titleText: TitleText?
    let titleType: TitleType?
}

struct TitleText: Codable {
    let text: String?
}

struct Thumbail: Codable {
    let id: String?
    let height: Int?
    let width: Int?
    let url: String?
//    let __typename: String?
//    let caption: Markdown?
}

//struct Markdown: Codable {
//    let __typename: String?
//    let plainText: String?
//}

struct ReleaseDate: Codable {
//    let __typename: String?
    let day: Int?
    let month: Int?
    let year: Int?
}

struct YearRange: Codable {
//    let __typename: String?
    let endYear: String?
    let year: Int?
}

struct TitleType: Codable {
//    let __typename: String?
    let id: String?
    let isEpisode: Bool?
    let isSeries: Bool?
    let text: String?
}
