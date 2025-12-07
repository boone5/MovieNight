//
//  CoreDataInfo.swift
//  Models
//
//  Created by Ayren King on 12/5/25.
//

import Foundation

public enum CoreDataInfo {
    static var bundle: Bundle { ModelsResources.bundle }
    public static var modelName: String { "FilmContainer" }
    public static var fileName: String { "Film.sqlite" }
    public static var modelURL: URL? {
        bundle.url(forResource: CoreDataInfo.modelName, withExtension: "momd")
    }
}
