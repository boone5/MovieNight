//
//  TargetDependency+App.swift
//  BundlePlugin
//
//  Created by Ayren King on 12/4/25.
//

import ProjectDescription

public extension TargetDependency {
    /// Returns the target dependency for a given app
    static func app(_ app: App) -> TargetDependency {
        .target(name: app.name)
    }
}

/// Provides references to project targets.
extension TargetReference {
    public static var app: TargetReference { .init(.app) }

    /// Initializes a target reference from an app.
    init(_ app: App) {
        self.init(stringLiteral: app.name)
    }
}
