//
//  Details_CD.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import Foundation
import CoreData

// Whenever we work with an object in CoreData it is a NSManagedObject
@objc(Movie)
public class Movie: NSManagedObject, DetailViewRepresentable {
    // Movie Properties
    @NSManaged public var id: Int64
    @NSManaged public var title: String
    @NSManaged public var overview: String
    @NSManaged public var dateWatched: Date
    @NSManaged public var releaseDate: String
    @NSManaged public var posterData: Data?
    @NSManaged public var posterPath: String?
}

extension Movie {
    var activityList: [Activity]? {
        let activities = value(forKey: "activityList") as? [Activity]
        return activities?.reversed()
    }

    var currentRating: Int16 {
        activityList?.first?.rating ?? 0
    }
}

extension Movie {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }
}

struct MovieData {
    let id: Int64
    let title: String
    let overview: String
    let dateWatched: Date
    let posterData: Data?
    let posterPath: String?

    init(from movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.dateWatched = movie.dateWatched
        self.posterData = movie.posterData
        self.posterPath = movie.posterPath
    }
}

//extension Movie_CD {
//    static func createCoreDataModel(from details: DetailViewRepresentable, in context: NSManagedObjectContext) -> Movie_CD {
//        let movie_CD = Movie_CD(context: context)
//        movie_CD.id = details.id
//        movie_CD.adult = details.adult
//        movie_CD.originalLanguage = details.originalLanguage
//        movie_CD.overview = details.overview
//        movie_CD.popularity = details.popularity
//        movie_CD.releaseDate = details.releaseDate
//        movie_CD.title = details.title
//        movie_CD.video = details.video
//        movie_CD.voteAverage = details.voteAverage
//        movie_CD.voteCount = details.voteCount
//        movie_CD.posterPath = details.posterPath
//
//        return movie_CD
//    }
//}
