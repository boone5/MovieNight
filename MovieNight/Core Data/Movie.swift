//
//  Details_CD.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import Foundation
import CoreData

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

extension Film: DetailViewRepresentable {
    var mediaType: MediaType {
        switch mediaTypeAsString {
        case MediaType.movie.rawValue:
                .movie
        case MediaType.tvShow.rawValue:
                .tvShow
        default:
                .movie
        }
    }
}

extension Film {
    public static func recentlyWatched() -> NSFetchRequest<Film> {
        let request: NSFetchRequest<Film> = .init(entityName: "Film")
        request.sortDescriptors = [NSSortDescriptor(key: "dateWatched", ascending: false)]
        request.predicate = NSPredicate(format: "dateWatched != nil")
        return request
    }
}
