//
//  NavigationTransitionConfig.swift
//  UI
//
//  Created by Ayren King on 12/11/25.
//

import Models
import SwiftUI

public struct NavigationTransitionConfiguration<ID: Hashable> {
    let namespace: Namespace.ID
    let sourceID: ID
}

public extension NavigationTransitionConfiguration where ID == Film.ID {
    /// Creates a zoom transition configuration for the given source.
    init(namespace: Namespace.ID, source: any DetailViewRepresentable) {
        self.namespace = namespace
        self.sourceID = source.id
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
