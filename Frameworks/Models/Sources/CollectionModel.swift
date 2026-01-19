//
//  CollectionModel.swift
//  Models
//
//  Created by Claude on 1/18/26.
//

import Foundation

/// A value type representation of FilmCollection for use in TCA state.
/// NSManagedObjects are reference types which don't trigger SwiftUI re-renders
/// when their properties change, so we project to this struct instead.
public struct CollectionModel: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public let type: CollectionType
    public let dateCreated: Date
    public let filmCount: Int

    public init(
        id: UUID,
        title: String,
        type: CollectionType,
        dateCreated: Date,
        filmCount: Int
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.dateCreated = dateCreated
        self.filmCount = filmCount
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
    }
}
