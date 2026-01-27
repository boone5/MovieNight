//
//  FilmCollection+Extensions.swift
//  MovieNight
//
//  Created by Boone on 5/26/25.
//

import Foundation

extension FilmCollection {
    public static let movieID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    public static let watchLaterID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!

    #if DEBUG
    public static let rankedListID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    public static let customListID = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    #endif
}

extension FilmCollection {
    public var type: CollectionType {
        get {
            CollectionType(rawValue: typeRawValue ?? "custom") ?? .custom
        }
        set {
            typeRawValue = newValue.rawValue
        }
    }

    public var safeTitle: String {
        self.title ?? ""
    }
}
