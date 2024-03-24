//
//  Details_CD.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import Foundation
import CoreData

// Whenever we work with an object in CoreData it is a NSManagedObject
final class Movie_CD: NSManagedObject, Identifiable {
    // Movie Properties
    @NSManaged var id: Int64

    // Additional Properties
    @NSManaged var userRating: Int16    // cannot be marked optional due to ObjC limitations. Might be able to use NSNumber instead
    @NSManaged var posterData: Data?

    override func awakeFromInsert() {
        super.awakeFromInsert()

        // set default values for optional params
        setPrimitiveValue(nil, forKey: "posterData")
        setPrimitiveValue(3, forKey: "userRating")
    }
}

extension Movie_CD {
    private static var contactsFetchRequest: NSFetchRequest<Movie_CD> {
        NSFetchRequest(entityName: "Movie_CD")
    }

    public static func all() -> NSFetchRequest<Movie_CD> {
        let fetchRequest: NSFetchRequest<Movie_CD> = contactsFetchRequest

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Movie_CD.userRating, ascending: false)
        ]

        return fetchRequest
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
