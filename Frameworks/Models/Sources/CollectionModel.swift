//
//  CollectionModel.swift
//  Models
//
//  Created by Claude on 1/18/26.
//

import Foundation

// FIXME: This might be able to be simplified whenever eventPublisher stuff is merged

/// A value type representation of FilmCollection for use in TCA state.
/// NSManagedObjects are reference types which don't trigger SwiftUI re-renders
/// when their properties change, so we project to this struct instead.
public struct CollectionModel: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public let type: CollectionType
    public let dateCreated: Date
    public var filmCount: Int
    public let posterPaths: [String?]

    public init(
        id: UUID,
        title: String,
        type: CollectionType,
        dateCreated: Date,
        filmCount: Int,
        posterPaths: [String?] = []
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.dateCreated = dateCreated
        self.filmCount = filmCount
        self.posterPaths = posterPaths
    }
}

extension CollectionModel {
    /// Creates a CollectionModel from a FilmCollection Core Data object
    public init(from collection: FilmCollection) {
        self.id = collection.id ?? UUID()
        self.title = collection.title ?? ""
        self.type = collection.type
        self.dateCreated = collection.dateCreated ?? Date()
        self.filmCount = collection.films?.count ?? 0

        let films = collection.films?.array as? [Film] ?? []
        self.posterPaths = films.prefix(3).map { $0.posterPath }
    }
}
