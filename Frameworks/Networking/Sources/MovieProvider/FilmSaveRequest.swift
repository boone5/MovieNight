//
//  FilmSaveRequest.swift
//  Frameworks
//
//  Created by Ayren King on 12/5/25.
//

import Models

public struct FilmSaveRequest {
    public let film: any DetailViewRepresentable
    public let comment: Comment?
    public let feedback: Feedback?

    public init(_ film: any DetailViewRepresentable, comment: Comment? = nil, feedback: Feedback? = nil) {
        self.film = film
        self.comment = comment
        self.feedback = feedback
    }
}

