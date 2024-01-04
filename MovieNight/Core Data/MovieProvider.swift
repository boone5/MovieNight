//
//  MovieProvider.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import Foundation
import CoreData

// Help us manage and interact with Data
// Should only have one instance to interact with memory
final class MovieProvider {
    static let shared = MovieProvider()

    private let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var newContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        return context
    }

    private init() { 

        persistentContainer = NSPersistentContainer(name: "DetailsDataModel")
        // whenever a change happens, it will automatically get saved
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("⛔️ Error loading store: \(error)")
            }
        }
    }

    func exists(_ movie: MovieDetails, in context: NSManagedObjectContext) -> MovieDetails? {
        try? context.existingObject(with: movie.objectID) as? MovieDetails
    }

    func persist(in context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
