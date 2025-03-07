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

    init(from response: DetailViewRepresentable) {
        self.id = response.id
        self.title = response.title ?? "-"
        self.overview = response.overview ?? "-"
        self.posterData = response.posterData
        self.posterPath = response.posterPath
        self.releaseDate = response.releaseDate
        self.mediaType = response.mediaType
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
