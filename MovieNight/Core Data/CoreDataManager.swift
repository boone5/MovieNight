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
final class CoreDataManager {
    static let shared = CoreDataManager()

    private let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var newContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        return context
    }

    private init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "FilmContainer")

        if inMemory {
            // tells Core Data to not actaully use a file (don't store something)
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("⛔️ Error loading store: \(error)")
            }
        }

        viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()

                print("✅ Successfully saved Movie into Core Data")
            } catch {
                print("⛔️ Error saving Movie into Core Data: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: SwiftUI Preview
extension CoreDataManager {
    static var preview: CoreDataManager = {
        let controller = CoreDataManager(inMemory: true)
        let viewContext = controller.viewContext

        return controller
    }()
//
//    static var previewMovie: Movie_CD = {
//        let controller = MovieProvider(inMemory: true)
//        let viewContext = controller.viewContext
//
//        let movie_CD = Movie_CD(context: viewContext)
//        movie_CD.id = Int64(1)
//        movie_CD.adult = true
//        movie_CD.originalLanguage = "en"
//        movie_CD.overview = "Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna. Ut enim ad minim veniam, quis"
//        movie_CD.popularity = 400
//        movie_CD.releaseDate = "2014-11-01"
//        movie_CD.title = "Movie 1"
//        movie_CD.video = true
//        movie_CD.voteAverage = 1
//        movie_CD.voteCount = 10000
//        movie_CD.posterPath = "/1QVZXQQHCEIj8lyUhdBYd2qOYtq.jpg"
//
//        return movie_CD
//    }()
}
