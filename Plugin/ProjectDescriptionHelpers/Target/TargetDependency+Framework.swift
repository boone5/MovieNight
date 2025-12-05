//
//  TargetDependency+Framework.swift
//  BundlePlugin
//
//  Created by Ayren King on 12/4/25.
//

import ProjectDescription

public extension TargetDependency {
    /// Returns the target dependency for a given framework.
    static func target(_ framework: Framework) -> TargetDependency {
        .target(name: framework.rawValue)
    }

    /// Returns the project dependency for a given framework.
    static func project(_ framework: Framework, from project: ProjectReference = .frameworks) -> TargetDependency {
        .project(target: framework.name, path: .relativeToRoot(project.rawValue))
    }
}

public extension ResourceFileElements {
    /// Returns the resources associated with a given framework.
    static func resources(_ framework: Framework) -> ResourceFileElements {
        return framework.resources
    }
}

public extension Target {
    /// Creates a target for a given framework.
    static func target(
        framework: Framework,
        resources: ResourceFileElements? = nil,
        headers: Headers? = nil,
        entitlements: Entitlements? = nil,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil,
        coreDataModels: [CoreDataModel] = [],
        environmentVariables: [String: EnvironmentVariable] = [:],
        launchArguments: [LaunchArgument] = [],
        additionalFiles: [FileElement] = [],
        buildRules: [BuildRule] = [],
        mergedBinaryType: MergedBinaryType = .disabled,
        mergeable: Bool = false,
        onDemandResourcesTags: OnDemandResourcesTags? = nil
    ) -> Target {
        .target(
            name: framework.name,
            destinations: .iOS,
            product: .framework,
            bundleId: .bundleId(for: framework.name),
            deploymentTargets: .minimumDeploymentTarget,
            infoPlist: .default,
            sources: framework.sources,
            resources: resources,
            entitlements: entitlements,
            scripts: scripts,
            dependencies: dependencies,
            settings: settings,
            coreDataModels: coreDataModels,
            additionalFiles: additionalFiles,
            buildRules: buildRules,
            mergedBinaryType: mergedBinaryType,
            mergeable: mergeable,
            onDemandResourcesTags: onDemandResourcesTags
        )
    }
}

