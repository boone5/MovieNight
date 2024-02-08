//
//  Details_CD.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import Foundation
import CoreData

// Whenever we work with an object in CoreData it is a NSManagedObject
final class Details_CD: NSManagedObject, DetailViewRepresentable, Identifiable {
    // Movie Properties
    @NSManaged var id: Int64
    @NSManaged var adult: Bool
    @NSManaged var originalLanguage: String
    @NSManaged var overview: String
    @NSManaged var popularity: Double
    @NSManaged var releaseDate: String
    @NSManaged var title: String
    @NSManaged var video: Bool
    @NSManaged var voteAverage: Double
    @NSManaged var voteCount: Int64
    @NSManaged var posterPath: String?

    // Additional Properties
    @NSManaged var userRating: Int16    // cannot be marked optional due to ObjC limitations. Might be able to use NSNumber instead
    @NSManaged var posterData: Data?

    override func awakeFromInsert() {
        super.awakeFromInsert()

        // set default values for optional params
        setPrimitiveValue(nil, forKey: "posterData")
        setPrimitiveValue(nil, forKey: "posterPath")
        setPrimitiveValue(3, forKey: "userRating")
    }
}

extension Details_CD {
    private static var contactsFetchRequest: NSFetchRequest<Details_CD> {
        NSFetchRequest(entityName: "Details_CD")
    }

    public static func all() -> NSFetchRequest<Details_CD> {
        let fetchRequest: NSFetchRequest<Details_CD> = contactsFetchRequest

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Details_CD.title, ascending: false)
        ]

        return fetchRequest
    }
}

extension Details_CD {
    static func createCoreDataModel(from details: DetailViewRepresentable, in context: NSManagedObjectContext) -> Details_CD {
        let movie_CD = Details_CD(context: context)
        movie_CD.id = details.id
        movie_CD.adult = details.adult
        movie_CD.originalLanguage = details.originalLanguage
        movie_CD.overview = details.overview
        movie_CD.popularity = details.popularity
        movie_CD.releaseDate = details.releaseDate
        movie_CD.title = details.title
        movie_CD.video = details.video
        movie_CD.voteAverage = details.voteAverage
        movie_CD.voteCount = details.voteCount
        movie_CD.posterPath = details.posterPath

        return movie_CD
    }
}
