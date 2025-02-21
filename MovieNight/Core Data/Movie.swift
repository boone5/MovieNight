//
//  Details_CD.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import Foundation
import CoreData

struct MovieData {
    let id: Int64
    let title: String
    let overview: String
    let dateWatched: Date?
    let posterData: Data?
    let posterPath: String?

    init(from movie: Film) {
        self.id = movie.id
        self.title = movie.title ?? "-"
        self.overview = movie.overview ?? "-"
        self.dateWatched = movie.dateWatched
        self.posterData = movie.posterData
        self.posterPath = movie.posterPath
    }
}
