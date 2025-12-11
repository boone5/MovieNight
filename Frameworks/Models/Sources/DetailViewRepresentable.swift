//
//  DetailViewRepresentable.swift
//  MovieNight
//
//  Created by Boone on 1/17/24.
//

import Foundation

public protocol DetailViewRepresentable: Identifiable {
    var id: Int64 { get }
    var overview: String? { get }
    var posterPath: String? { get }
    var releaseDate: String? { get }
    var title: String? { get }
    var mediaType: MediaType { get }

    // Additional Properties
    var posterData: Data? { get }
}
