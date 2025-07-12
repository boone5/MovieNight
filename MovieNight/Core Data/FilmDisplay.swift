//
//  FilmDisplay.swift
//  MovieNight
//
//  Created by Boone on 5/26/25.
//

import Foundation

struct FilmDisplay: DetailViewRepresentable {
    let id: Int64
    let title: String?
    let overview: String?
    let posterData: Data?
    let posterPath: String?
    let releaseDate: String?
    let mediaType: MediaType
    let hasTrailer: Bool

    var comments: [Comment]

    init(from film: DetailViewRepresentable) {
        self.id = film.id
        self.title = film.title ?? "-"
        self.overview = film.overview ?? "-"
        self.posterData = film.posterData
        self.posterPath = film.posterPath
        self.releaseDate = film.releaseDate
        self.mediaType = film.mediaType
        self.hasTrailer = film.hasTrailer
        self.comments = []
    }

    init(from film: Film) {
        self.id = film.id
        self.title = film.title ?? "-"
        self.overview = film.overview ?? "-"
        self.posterData = film.posterData
        self.posterPath = film.posterPath
        self.releaseDate = film.releaseDate
        self.mediaType = film.mediaType
        self.hasTrailer = film.hasTrailer

        let comments = film.comments?.array as? [Comment] ?? []
        self.comments = comments
    }
}
