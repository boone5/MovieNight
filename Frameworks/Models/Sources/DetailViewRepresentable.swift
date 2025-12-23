//
//  DetailViewRepresentable.swift
//  MovieNight
//
//  Created by Boone on 1/17/24.
//

import Foundation

public protocol DetailViewRepresentable: Identifiable, Hashable {
    var id: Int64 { get }
    var mediaType: MediaType { get }
    var title: String { get }
    var overview: String? { get }
    var posterPath: String? { get }
}
