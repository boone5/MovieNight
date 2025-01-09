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

    static let preview: MovieProvider = {
        let controller = MovieProvider(inMemory: true)
        return controller
    }()

    private let inMemory: Bool

    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }

    /// A persistent container to set up the Core Data stack.
    lazy var container: NSPersistentContainer = {
        /// - Tag: persistentContainer
        let container = NSPersistentContainer(name: "FilmContainer")
        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()

        let movieStoreURL = defaultDirectoryURL.appendingPathComponent("Movie.sqlite")
        let movieStoreDescription = NSPersistentStoreDescription(url: movieStoreURL)
        movieStoreDescription.configuration = "Movie"

        let feedbackStoreURL = defaultDirectoryURL.appendingPathComponent("Activity.sqlite")
        let feedbackStoreDescription = NSPersistentStoreDescription(url: feedbackStoreURL)
        feedbackStoreDescription.configuration = "Activity"

        container.persistentStoreDescriptions = [movieStoreDescription, feedbackStoreDescription]

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // This sample refreshes UI by consuming store changes via persistent history tracking.
        /// - Tag: viewContextMergeParentChanges
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"

        // From Earthquakes project. Not sure if I need it
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()

                print("✅ Successfully saved Movie into Core Data")
            } catch {
                print("⛔️ Error saving Movie into Core Data: \(error.localizedDescription)")
            }
        }
    }

    @discardableResult
    public func filmExists(_ id: Int64) -> Bool {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        fetchRequest.fetchLimit = 1  // Limit to improve performance

        do {
            let count = try container.viewContext.count(for: fetchRequest)
            if count > 0 {
                return true
            }
            else {
                return false
            }

        } catch {
            print("Error checking if film exists: \(error)")
            return false
        }
    }

    func fetchMovieByID(_ id: Int64) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        fetchRequest.fetchLimit = 1

        do {
            let results = try container.viewContext.fetch(fetchRequest)
            if let movie = results.first {
                return movie
            } else {
                print("No movie found with ID \(id)")
            }
        } catch {
            print("Error fetching movie for deletion: \(error)")
        }

        return nil
    }

    func fetchMoviesSortedByDateWatched() -> [Movie] {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()

        // Create a sort descriptor to sort by release date
        let sortDescriptor = NSSortDescriptor(key: "dateWatched", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            let movies = try container.viewContext.fetch(fetchRequest)
            return movies
        } catch {
            print("Error fetching movies: \(error)")
            return []
        }
    }

    @discardableResult
    public func saveFilm(_ film: DetailViewRepresentable, feedback: Activity? = nil) -> Movie {
        let movie = Movie(context: container.viewContext)
        movie.title = film.title
        movie.id = film.id
        movie.dateWatched = Date()
        movie.posterPath = film.posterPath
        movie.overview = film.overview
        movie.releaseDate = film.releaseDate
        movie.activity = feedback

        if let context = movie.managedObjectContext {
            do {
                try context.save()
            } catch {
                print("Failed to save: \(error)")
            }
        }
        return movie
    }

    /// Optionally, if you prefer removing by an ID, you can implement a method like this:
    /// - Parameter id: The ID of the movie to remove.
    public func deleteMovie(by id: Int64) {
        if let movieToDelete = fetchMovieByID(id) {
            container.viewContext.delete(movieToDelete)
            saveContext()
        }
    }
}
