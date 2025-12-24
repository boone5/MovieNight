//
//  LiveMovieProvider.swift
//  Networking
//
//  Created by Ayren King on 12/5/25.
//

import CoreData
import Dependencies
import Foundation
import Logger
import Models

public class MovieProvider: MovieProviderClient {
    @Dependency(\.logger.log) var log
    private let inMemory: Bool

    internal init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }

    /// A persistent container to set up the Core Data stack.
    public lazy var container: NSPersistentContainer = {
        NSPersistentContainer.filmContainer(inMemory: inMemory)
    }()

    public func save() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                log(.movieProvider, .info, "✅ Successfully saved Movie into Core Data")
            } catch {
                log(.movieProvider, .error, "⛔️ Error saving Movie into Core Data: \(error.localizedDescription)")
            }
        }
    }

    public func fetchFilm(_ id: Film.ID) -> Film? {
        let fetchRequest: NSFetchRequest<Film> = Film.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        fetchRequest.fetchLimit = 1

        do {
            let results = try container.viewContext.fetch(fetchRequest)
            if let movie = results.first {
                return movie
            }
        } catch {
            log(.movieProvider, .error, "⛔️ Error fetching film: \(error.localizedDescription)")
        }

        return nil
    }

    public func fetchCollection(_ id: UUID) -> FilmCollection? {
        let request: NSFetchRequest<FilmCollection> = FilmCollection.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            return try container.viewContext.fetch(request).first
        } catch {
            log(.movieProvider, .error, "⛔️ Error fetching Collection: \(error)")
            return nil
        }
    }

    @discardableResult
    public func saveFilmToLibrary(_ request: FilmSaveRequest) throws(MovieError) -> Film {
        let movie = Film(context: container.viewContext)
        movie.title = request.film.title
        movie.id = request.film.id
        movie.dateWatched = Date()
        movie.posterPath = request.film.posterPath
        movie.overview = request.film.overview
//        movie.releaseDate = request.film.releaseDate
        movie.feedback = request.feedback

        if let comment = request.comment {
            movie.addToComments(comment)
        }

        switch request.film.mediaType {
        case .movie:
            // add to movie collection
            if let movieCollection = fetchCollection(FilmCollection.movieID) {
                movieCollection.addToFilms(movie)
                movie.collection = movieCollection
            }

        case .tv:
            // add to tvshow collection
            if let tvShowCollection = fetchCollection(FilmCollection.tvShowID) {
                tvShowCollection.addToFilms(movie)
                movie.collection = tvShowCollection
            }
        case .person:
            // TODO: maybe handle person type later
            break
        }

        if let context = movie.managedObjectContext {
            do {
                try context.save()
            } catch {
                log(.movieProvider, .error, "⛔️ Failed to save: \(error)")
                throw MovieError.unableToSaveFilm
            }
        }
        return movie
    }

    @discardableResult
    public func saveFilmToWatchLater(_ film: MediaItem) throws(MovieError) -> Film {
        let filmCD = Film(context: container.viewContext)
        filmCD.title = film.title
        filmCD.id = film.id
        filmCD.dateWatched = nil
        filmCD.posterPath = film.posterPath
        filmCD.overview = film.overview
        filmCD.releaseDate = film.releaseDate
        filmCD.isOnWatchList = true

        if let watchLaterCollection = fetchCollection(FilmCollection.watchLaterID) {
            watchLaterCollection.addToFilms(filmCD)
            filmCD.collection = watchLaterCollection
        }

        if let context = filmCD.managedObjectContext {
            do {
                try context.save()
            } catch {
                log(.movieProvider, .error, "⛔️ Failed to save: \(error)")
                throw MovieError.unableToSaveFilm
            }
        }
        return filmCD
    }

    public func deleteFilm(_ id: Film.ID) throws(MovieError) {
        guard  let movieToDelete = fetchFilm(id) else {
            throw MovieError.filmNotFound
        }
        container.viewContext.delete(movieToDelete)
        save()
    }

    /// Loads default Collections into Core Data
    public func prepareDefaultCollections() throws(MovieError) {
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

                log(.movieProvider, .info, "✅ Default collections added!")
            }
        } catch {
            log(.movieProvider, .error, "⛔️ Error preloading default data: \(error)")
        }
    }
}

extension NSPersistentContainer {
    static func filmContainer(inMemory: Bool) -> NSPersistentContainer {
        guard let modelURL = CoreDataInfo.modelURL, let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to load the managed object model.")
        }

        let container = NSPersistentContainer(name: CoreDataInfo.modelName, managedObjectModel: managedObjectModel)
        let movieStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent(CoreDataInfo.fileName)
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
    }
}

public enum MovieError: Error {
    case unableToSaveFilm
    case filmNotFound
}
