//
//  Film.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import CoreData

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

    public static func watchedSeason(_ season: AdditionalDetailsTVShow.SeasonResponse) {

    }
}
