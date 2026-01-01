//
//  FilmSaveRequest.swift
//  Frameworks
//
//  Created by Ayren King on 12/5/25.
//

import Models

public struct FilmSaveRequest {
    public let film: MediaItem
    public let comment: Comment?

    public init(_ film: MediaItem, comment: Comment? = nil) {
        self.film = film
        self.comment = comment
    }
}

