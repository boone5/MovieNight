//
//  CollectionType.swift
//  App
//
//  Created by Boone on 12/17/25.
//

enum CollectionType: String, Equatable, CaseIterable {
    case custom
    case ranked
    case smart

    var title: String {
        switch self {
        case .custom: "Custom Collection"
        case .ranked: "Ranked Collection"
        case .smart: "Smart Collection"
        }
    }

    var icon: String {
        switch self {
        case .custom: "folder.fill"
        case .ranked: "chart.bar.fill"
        case .smart: "sparkles"
        }
    }
}
