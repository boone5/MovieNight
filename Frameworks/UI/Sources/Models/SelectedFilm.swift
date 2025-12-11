//
//  SelectedFilm.swift
//  Frameworks
//
//  Created by Ayren King on 12/5/25.
//

import Models
import UIKit

public struct SelectedFilm: Identifiable, Equatable {
    public var id: Int64
    public var film: any DetailViewRepresentable

    public init(film: any DetailViewRepresentable) {
        self.id = film.id
        self.film = film
    }

    public static func ==(lhs: SelectedFilm, rhs: SelectedFilm) -> Bool {
        lhs.id == rhs.id
    }
}
