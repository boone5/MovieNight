//
//  CollectionType.swift
//  Models
//
//  Created by Boone on 12/17/25.
//

import Foundation

public enum CollectionType: String, Equatable, CaseIterable, Sendable {
    case custom
    case ranked
    case watchList

    public var title: String {
        switch self {
        case .custom: "Custom"
        case .ranked: "Ranked"
        case .watchList: "Watch List"
        }
    }

    public var icon: String {
        switch self {
        case .custom: "folder.fill"
        case .ranked: "chart.bar.fill"
        case .watchList: "list.bullet.rectangle.fill"
        }
    }

    public var subtitle: String {
        switch self {
        case .custom: "Group however you like"
        case .ranked: "Order from best to worst"
        case .watchList: "Group what to watch next"
        }
    }
}
