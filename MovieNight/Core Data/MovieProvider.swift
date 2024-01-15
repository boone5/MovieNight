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
        
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("⛔️ Error loading store: \(error)")
            }
        }

        viewContext.automaticallyMergesChangesFromParent = true
    }

    func exists(id: Int64) -> MovieDetails? {
        let fetchRequest: NSFetchRequest<MovieDetails> = MovieDetails.all()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            let existingMovies = try viewContext.fetch(fetchRequest)
            return existingMovies.first
        } catch {
            print("Error checking for existing movie: \(error)")
            return nil
        }
    }

    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()

                print("✅ Successfully saved Movie into Core Data")
            } catch {
                print("⛔️ Error saving Movie into Core Data: \(error.localizedDescription)")
            }
        }
    }

    func update(entity: MovieDetails, userRating: Int16) {
        entity.userRating = userRating

        self.save()
    }

    func fetch() -> [MovieDetails] {
        var results: [MovieDetails] = []

        do {
            results = try viewContext.fetch(MovieDetails.all())
        } catch {
            print("⛔️ Error fetching Movie Details from Core Data: \(error.localizedDescription)")
        }

        return results
    }
}
