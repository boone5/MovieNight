//
//  Framework.swift
//  BundlePlugin
//
//  Created by Ayren King on 12/4/25.
//

import ProjectDescription

public enum Framework: String {
    case logger = "Logger"
    case models = "Models"
    case networking = "Networking"
    case search = "Search"
    case ui = "UI"

    public var name: String {
        rawValue
    }

    public var testTargetName: String {
        "\(rawValue)Tests"
    }

    public var sources: SourceFilesList {
        ["\(rawValue)/Sources/**"]
    }

    public var testSources: SourceFilesList {
        "\(rawValue)/Tests/**"
    }

    public var resources: ResourceFileElements {
        ["\(rawValue)/Resources/**"]
    }
}
