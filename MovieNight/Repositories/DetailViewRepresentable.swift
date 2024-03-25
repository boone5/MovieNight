//
//  DetailViewRepresentable.swift
//  MovieNight
//
//  Created by Boone on 1/17/24.
//

import Foundation

protocol DetailViewRepresentable {
    var id: Int64 { get }
    var adult: Bool? { get }
    var originalLanguage: String { get }
    var overview: String { get }
    var popularity: Double { get }
    var posterPath: String? { get }
    var releaseDate: String { get }
    var title: String { get }
    var video: Bool { get }
    var voteAverage: Double { get }
    var voteCount: Int64 { get }

    // Additional Properties
    var userRating: Int16 { get set }
    var posterData: Data? { get set }
}
