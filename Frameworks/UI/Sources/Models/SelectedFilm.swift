//
//  SelectedFilm.swift
//  Frameworks
//
//  Created by Ayren King on 12/5/25.
//

import Models
import UIKit

public struct SelectedFilm {
    public var id: Int64
    public var film: DetailViewRepresentable
    public var posterImage: UIImage?

    public init(id: Int64, film: DetailViewRepresentable, posterImage: UIImage? = nil) {
        self.id = id
        self.film = film
        self.posterImage = posterImage
    }
}
