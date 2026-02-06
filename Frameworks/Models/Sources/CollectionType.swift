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

extension CollectionType {
    public enum Action {
        case addFilm
        case reorder
        case rename

        var title: String {
            switch self {
            case .addFilm: "Add"
            case .reorder: "Reorder"
            case .rename:  "Rename"
            }
        }

        public var icon: String {
            switch self {
            case .addFilm: "plus"
            case .reorder: "arrow.trianglehead.swap"
            case .rename:  "pencil"
            }
        }
    }

    public var actions: [Action] {
        switch self {
        case .custom:
            [.addFilm, .rename]
        case .ranked:
            [.addFilm, .rename, .reorder]
        case .watchList:
            [.addFilm, .rename]
        }
    }
}
