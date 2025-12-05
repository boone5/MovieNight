//
//  UnitTestFramework.swift
//  BundlePlugin
//
//  Created by Ayren King on 3/31/25.
//

import ProjectDescription

public extension Target {
    /// Creates a unit test target for a given framework.
    static func unitTests(for mainTarget: Framework, extraDependencies: [TargetDependency] = []) -> Target {
        .target(
            name: mainTarget.testTargetName,
            destinations: .iOS,
            product: .unitTests,
            bundleId: .bundleId(for: mainTarget.testTargetName),
            deploymentTargets: .minimumDeploymentTarget,
            infoPlist: .default,
            sources: mainTarget.testSources,
            dependencies: [.target(mainTarget)] + extraDependencies
        )
    }

    /// Creates a unit test target for a given app.
    static func unitTests(for app: App, extraDependencies: [TargetDependency] = []) -> Target {
        .target(
            name: app.unitTestName,
            destinations: .iOS,
            product: .unitTests,
            bundleId: .bundleId(for: app.unitTestName),
            deploymentTargets: .minimumDeploymentTarget,
            infoPlist: .default,
            sources: app.unitTestSources,
            dependencies: [.app(app)] + extraDependencies
        )
    }

    /// Creates a UI test target for a given app.
    static func uiTests(for app: App, extraDependencies: [TargetDependency] = []) -> Target {
        .target(
            name: app.uiTestName,
            destinations: .iOS,
            product: .unitTests,
            bundleId: .bundleId(for: app.uiTestName),
            deploymentTargets: .minimumDeploymentTarget,
            infoPlist: .default,
            sources: app.uiTestSources,
            dependencies: [.app(app)] + extraDependencies
        )
    }
}
