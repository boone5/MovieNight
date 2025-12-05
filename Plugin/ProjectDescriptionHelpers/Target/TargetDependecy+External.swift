//
//  TargetDependecy+External.swift
//  BundlePlugin
//
//  Created by Ayren King on 12/4/25.
//

import ProjectDescription

public extension TargetDependency {
    /// Creates a target dependency for an external framework.
    static func external(_ framework: ExternalFramework) -> TargetDependency {
        .external(name: framework.name)
    }
}
