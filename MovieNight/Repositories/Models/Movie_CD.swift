//
//  Movie_CD.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import Foundation
import CoreData

// Whenever we work with an object in CoreData it is a NSManagedObject
final class MovieDetails: NSManagedObject, Identifiable {

    // Movie Properties
    @NSManaged var adult: Bool
    @NSManaged var originalLanguage: String
    @NSManaged var overview: String
    @NSManaged var popularity: Double
    @NSManaged var releaseDate: String
    @NSManaged var title: String
    @NSManaged var video: Bool
    @NSManaged var voteAverage: Double
    @NSManaged var voteCount: Int16
    @NSManaged var posterPath: String?

    // Additional Properties
    @NSManaged var userRating: Int
    @NSManaged var posterData: Data?

    override func awakeFromInsert() {
        super.awakeFromInsert()

        // set default values for optional params
        setPrimitiveValue(nil, forKey: "posterData")
        setPrimitiveValue(nil, forKey: "posterPath")
        setPrimitiveValue(3, forKey: "userRating")
    }
}

extension MovieDetails {
    static func createMovie(from details: MovieResponseTMDB.Details, in context: NSManagedObjectContext) -> MovieDetails {
        let movie_CD = MovieDetails(context: context)
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
