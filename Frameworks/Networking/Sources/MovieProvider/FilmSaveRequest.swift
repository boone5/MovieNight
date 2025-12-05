//
//  FilmSaveRequest.swift
//  Frameworks
//
//  Created by Ayren King on 12/5/25.
//

import Models

public struct FilmSaveRequest: Equatable {
    public let film: Film
    public let comment: Comment?
    public let isLiked: Bool
    public let isDisliked: Bool
    public let isLoved: Bool

    public init(film: Film, comment: Comment? = nil, isLiked: Bool, isDisliked: Bool, isLoved: Bool) {
        self.film = film
        self.comment = comment
        self.isLiked = isLiked
        self.isDisliked = isDisliked
        self.isLoved = isLoved
    }
}

