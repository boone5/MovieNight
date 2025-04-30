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

        let movieStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Film.sqlite")
        let movieStoreDescription = NSPersistentStoreDescription(url: movieStoreURL)
        movieStoreDescription.configuration = "Default"

        container.persistentStoreDescriptions = [movieStoreDescription]

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
        let fetchRequest: NSFetchRequest<Film> = Film.fetchRequest()
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

    func fetchFilmByID(_ id: Int64) -> Film? {
        let fetchRequest: NSFetchRequest<Film> = Film.fetchRequest()
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

    func fetchCollection(withIdentifier id: UUID) -> FilmCollection? {
        let request: NSFetchRequest<FilmCollection> = FilmCollection.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            return try container.viewContext.fetch(request).first
        } catch {
            print("⛔️ Error fetching Collection from Core Data: \(error)")
            return nil
        }
    }

    @discardableResult
    public func saveFilmToLibrary(_ film: DetailViewRepresentable, comment: Comment? = nil, isLiked: Bool, isDisliked: Bool, isLoved: Bool) -> Film {
        let movie = Film(context: container.viewContext)
        movie.title = film.title
        movie.id = film.id
        movie.dateWatched = Date()
        movie.posterPath = film.posterPath
        movie.overview = film.overview
        movie.releaseDate = film.releaseDate
        movie.isLiked = isLiked
        movie.isDisliked = isDisliked
        movie.isLoved = isLoved

        if let comment {
            movie.addToComments(comment)
        }

        switch film.mediaType {
        case .movie:
            // add to movie collection
            if let movieCollection = fetchCollection(withIdentifier: FilmCollection.movieID) {
                movieCollection.addToFilms(movie)
                movie.collection = movieCollection
            }

        case .tvShow:
            // add to tvshow collection
            if let tvShowCollection = fetchCollection(withIdentifier: FilmCollection.tvShowID) {
                tvShowCollection.addToFilms(movie)
                movie.collection = tvShowCollection
            }
        }

        if let context = movie.managedObjectContext {
            do {
                try context.save()
            } catch {
                print("Failed to save: \(error)")
            }
        }
        return movie
    }

    public func saveFilmToWatchLater(_ film: DetailViewRepresentable) {
        let filmCD = Film(context: container.viewContext)
        filmCD.title = film.title
        filmCD.id = film.id
        filmCD.dateWatched = nil
        filmCD.posterPath = film.posterPath
        filmCD.overview = film.overview
        filmCD.releaseDate = film.releaseDate
        filmCD.isOnWatchList = true

        if let watchLaterCollection = fetchCollection(withIdentifier: FilmCollection.watchLaterID) {
            watchLaterCollection.addToFilms(filmCD)
            filmCD.collection = watchLaterCollection
        }

        if let context = filmCD.managedObjectContext {
            do {
                try context.save()
            } catch {
                print("Failed to save: \(error)")
            }
        }
    }

    public func deleteMovie(by id: Int64) {
        if let movieToDelete = fetchFilmByID(id) {
            container.viewContext.delete(movieToDelete)
            saveContext()
        }
    }

    /// Loads default Collections into Core Data
    func preloadDefaultCollectionsIfNeeded() {
        // Get the managed object context from your Core Data stack
        let context = container.viewContext

        let fetchRequest: NSFetchRequest<FilmCollection> = FilmCollection.fetchRequest()

        do {
            let count = try context.count(for: fetchRequest)

            // If count is 0, the store is empty and we need to seed it
            if count == 0 {
                let movieCollection = FilmCollection(context: context)
                movieCollection.id = FilmCollection.movieID
                movieCollection.title = "Movies"
                movieCollection.imageName = "movieclapper"
                movieCollection.dateCreated = Date()

                let tvShowCollection = FilmCollection(context: context)
                tvShowCollection.id = FilmCollection.tvShowID
                tvShowCollection.title = "TV Shows"
                tvShowCollection.imageName = "rectangle.portrait.on.rectangle.portrait.angled"
                tvShowCollection.dateCreated = Date()

                let watchLaterCollection = FilmCollection(context: context)
                watchLaterCollection.id = FilmCollection.watchLaterID
                watchLaterCollection.title = "Watch Later"
                watchLaterCollection.imageName = "text.badge.checkmark"
                watchLaterCollection.dateCreated = Date()

                try context.save()

                print("✅ Default collections added!")
            }
        } catch {
            print("⛔️ Error preloading default data: \(error)")
        }
    }
}

extension FilmCollection {
    static let movieID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let tvShowID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let watchLaterID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
}
