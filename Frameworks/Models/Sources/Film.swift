//
//  Film.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import CoreData

extension Film: DetailViewRepresentable {
    public var title: String {
        displayTitle ?? "Unknown"
    }

    public var mediaType: MediaType {
        switch mediaTypeAsString {
        case MediaType.movie.rawValue:
                .movie
        case MediaType.tv.rawValue:
                .tv
        case MediaType.person.rawValue:
                .person
        default:
                .movie
        }
    }

    /// User feedback for the film.
    public var feedback: Feedback? {
        get {
            guard let feedbackType else { return nil }
            return Feedback(rawValue: feedbackType)
        }
        set {
            feedbackType = newValue?.rawValue
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
