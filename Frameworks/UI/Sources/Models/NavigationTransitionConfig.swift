//
//  NavigationTransitionConfig.swift
//  UI
//
//  Created by Ayren King on 12/11/25.
//

import Models
import SwiftUI

/// A media item paired with a unique transition source identifier.
public struct TransitionableMedia: Identifiable, Equatable {
    public let item: MediaItem
    public let sourceID: String

    public init(item: MediaItem, id: String? = nil) {
        self.item = item
        
        if let id {
            self.sourceID = id
        } else {
            self.sourceID = item.id.description
        }
    }

    public var id: String { sourceID }
}

public struct NavigationTransitionConfiguration<ID: Hashable> {
    let namespace: Namespace.ID
    let sourceID: ID
}

public extension NavigationTransitionConfiguration where ID == MediaItem.ID {
    /// Creates a zoom transition configuration for the given source.
    init(namespace: Namespace.ID, source: MediaItem) {
        self.namespace = namespace
        self.sourceID = source.id
    }
}

public extension NavigationTransitionConfiguration where ID == String {
    /// Creates a zoom transition configuration for a custom id
    init(namespace: Namespace.ID, id: String) {
        self.namespace = namespace
        self.sourceID = id
    }

    /// Creates a zoom transition configuration from a TransitionableMedia wrapper.
    init(namespace: Namespace.ID, source: TransitionableMedia) {
        self.namespace = namespace
        self.sourceID = source.sourceID
    }
}

public extension View {
    /// Applies a zoom navigation transition using the provided configuration.
    func zoomTransition<ID: Hashable>(configuration: NavigationTransitionConfiguration<ID>) -> some View {
        navigationTransition(.zoom(sourceID: configuration.sourceID, in: configuration.namespace))
    }

    /// Marks the view as a zoom transition source using the provided configuration.
    func zoomSource<ID: Hashable>(configuration: NavigationTransitionConfiguration<ID>) -> some View {
        matchedTransitionSource(id: configuration.sourceID, in: configuration.namespace)
    }
}
