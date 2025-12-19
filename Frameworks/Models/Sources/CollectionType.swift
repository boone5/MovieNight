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
    case smart

    /*
     custom color: gradient of single color
     ranked color: gradient of single color
     smart color: some sort.padding(.horizontal, 6) of gradient of many colors
     */

    public var title: String {
        switch self {
        case .custom: "Custom"
        case .ranked: "Ranked"
        case .smart: "Smart"
        }
    }

    public var icon: String {
        switch self {
        case .custom: "folder.fill"
        case .ranked: "chart.bar.fill"
        case .smart: "sparkles"
        }
    }

    public var subtitle: String {
        switch self {
        case .custom: "Group however you like"
        case .ranked: "Order from best to worst"
        case .smart: "Auto-updates based on filters"
        }
    }
}
