//
//  SelectedFilm.swift
//  Frameworks
//
//  Created by Ayren King on 12/5/25.
//

import Models
import UIKit

public struct SelectedFilm: Equatable {
    public var id: Int64
    public var film: DetailViewRepresentable
    public var posterImage: UIImage?

    public init(film: DetailViewRepresentable, posterImage: UIImage? = nil) {
        self.id = film.id
        self.film = film
        self.posterImage = posterImage
    }

    public static func ==(lhs: SelectedFilm, rhs: SelectedFilm) -> Bool {
        lhs.id == rhs.id
    }
}
