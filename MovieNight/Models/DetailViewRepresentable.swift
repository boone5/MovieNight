//
//  DetailViewRepresentable.swift
//  MovieNight
//
//  Created by Boone on 1/17/24.
//

import Foundation

protocol DetailViewRepresentable {
    var id: Int64 { get }
    var overview: String { get }
    var posterPath: String? { get }
    var releaseDate: String { get }
    var title: String { get }

    // Additional Properties
    var posterData: Data? { get }
}
