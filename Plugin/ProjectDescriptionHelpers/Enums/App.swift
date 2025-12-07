//
//  App.swift
//  BundlePlugin
//
//  Created by Ayren King on 12/4/25.
//

import ProjectDescription

public enum App {
    case app

    public var name: String {
        switch self {
        case .app:
            return "App"
        }
    }

    public var productName: String? {
        switch self {
        case .app:
            return "Pop'n"
        }
    }

    public var bundleIdentifier: String {
        switch self {
        case .app:
            return .bundleId(for: name)
        }
    }

    public var deploymentTargets: DeploymentTargets {
        switch self {
        case .app:
            return .minimumDeploymentTarget
        }
    }

    public var infoPlist: InfoPlist {
        switch self {
        case .app:
            .default
        }
    }

    public var entitlements: Entitlements? {
        switch self {
        case .app:
            return nil
        }
    }

    public var sources: SourceFilesList {
        switch self {
        case .app:
            return ["App/Sources/**"]
        }
    }

    public var resources: ResourceFileElements {
        switch self {
        case .app:
            return ["App/Resources/**"]
        }
    }

    public var unitTestName: String {
        "\(name)Tests"
    }

    public var unitTestSources: SourceFilesList {
        ["\(name)/Tests/**"]
    }

    public var uiTestName: String {
        "\(name)UITests"
    }

    public var uiTestSources: SourceFilesList {
        ["\(name)/UITests/**"]
    }
}
