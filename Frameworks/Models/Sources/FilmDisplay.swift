//
//  FilmDisplay.swift
//  MovieNight
//
//  Created by Boone on 5/26/25.
//

import Foundation

public struct FilmDisplay: DetailViewRepresentable {
    public let id: Int64
    public let title: String?
    public let overview: String?
    public let posterData: Data?
    public let posterPath: String?
    public let releaseDate: String?
    public let mediaType: MediaType

    public var comments: [Comment]

    public init(from film: DetailViewRepresentable) {
        self.id = film.id
        self.title = film.title ?? "-"
        self.overview = film.overview ?? "-"
        self.posterData = film.posterData
        self.posterPath = film.posterPath
        self.releaseDate = film.releaseDate
        self.mediaType = film.mediaType
        self.comments = []
    }

    public init(from film: Film) {
        self.id = film.id
        self.title = film.title ?? "-"
        self.overview = film.overview ?? "-"
        self.posterData = film.posterData
        self.posterPath = film.posterPath
        self.releaseDate = film.releaseDate
        self.mediaType = film.mediaType

        let comments = film.comments?.array as? [Comment] ?? []
        self.comments = comments
    }
}
