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
        movie.releaseDate = request.film.releaseDate
        movie.isLiked = request.isLiked
        movie.isDisliked = request.isDisliked
        movie.isLoved = request.isLoved

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

        case .tvShow:
            // add to tvshow collection
            if let tvShowCollection = fetchCollection(FilmCollection.tvShowID) {
                tvShowCollection.addToFilms(movie)
                movie.collection = tvShowCollection
            }
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
    public func saveFilmToWatchLater(_ film: DetailViewRepresentable) throws(MovieError) -> Film {
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
        guard let movieToDelete = fetchFilm(id) else {
            throw MovieError.filmNotFound
        }
        container.viewContext.delete(movieToDelete)
        save()
    }

    public func deleteCollection(_ id: UUID) throws(MovieError) {
        guard let collectionToDelete = fetchCollection(id) else {
            throw MovieError.collectionNotFound
        }
        container.viewContext.delete(collectionToDelete)
        save()
    }

    public func renameCollection(_ id: UUID, to newTitle: String) throws(MovieError) {
        guard let collection = fetchCollection(id) else {
            throw MovieError.collectionNotFound
        }
        collection.title = newTitle
        save()
        container.viewContext.refresh(collection, mergeChanges: true)
    }

    @discardableResult
    public func createCollection(name: String, type: CollectionType) throws(MovieError) -> FilmCollection {
        let collection = FilmCollection(context: container.viewContext)
        collection.id = UUID()
        collection.title = name
        collection.dateCreated = Date()
        collection.type = type

        do {
            try container.viewContext.save()
            log(.movieProvider, .info, "✅ Successfully created collection: \(name)")
            return collection
        } catch {
            log(.movieProvider, .error, "⛔️ Failed to create collection: \(error)")
            throw MovieError.unableToSaveCollection
        }
    }

    // TODO: Change to Liked, Disliked, Loved as smart collections

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
                movieCollection.title = "Recently Watched"
                movieCollection.imageName = "movieclapper"
                movieCollection.dateCreated = Date()
                movieCollection.type = .custom

//                let posterPaths = [
//                    "/jNsttCWZyPtW66MjhUozBzVsRb7.jpg",
//                    "/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg",
//                    "/d5NXSklXo0qyIYkgV94XAgMIckC.jpg",
//                    "/rCzpDGLbOoPwLjy3OAm5NUPOTrC.jpg",
//                    "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
//                    "/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg",
//                    "/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg",
//                    "/nBNZadXqJSdt05SHLqgT0HuC5Gm.jpg",
//                    "/kqjL17yufvn9OVLyXYpvtyrFfak.jpg",
//                    "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg"
//                ]
//
//                let filmTitles = [
//                    "The Shawshank Redemption",
//                    "The Godfather",
//                    "The Dark Knight",
//                    "Pulp Fiction",
//                    "Fight Club",
//                    "Inception",
//                    "The Matrix",
//                    "Goodfellas",
//                    "Se7en",
//                    "The Silence of the Lambs"
//                ]
//
//                // Create a ranked collection with films
//                let rankedCollection = FilmCollection(context: context)
//                rankedCollection.id = UUID()
//                rankedCollection.title = "Top 10 Films"
//                rankedCollection.dateCreated = Date()
//                rankedCollection.type = .ranked
//
//                for i in 0..<10 {
//                    let film = Film(context: context)
//                    film.id = Int64(1000 + i)
//                    film.title = filmTitles[i]
//                    film.posterPath = posterPaths[i]
//                    film.releaseDate = "199\(i)-01-01"
//                    film.collection = rankedCollection
//                }
//
//                // Create a custom collection with films
//                let customCollection = FilmCollection(context: context)
//                customCollection.id = UUID()
//                customCollection.title = "My Favorites"
//                customCollection.dateCreated = Date()
//                customCollection.type = .custom
//
//                for i in 0..<5 {
//                    let film = Film(context: context)
//                    film.id = Int64(2000 + i)
//                    film.title = filmTitles[i]
//                    film.posterPath = posterPaths[i]
//                    film.releaseDate = "200\(i)-01-01"
//                    film.collection = customCollection
//                }
//
//                // Create a smart collection (empty for now)
//                let smartCollection = FilmCollection(context: context)
//                smartCollection.id = UUID()
//                smartCollection.title = "Unwatched Sci-Fi"
//                smartCollection.dateCreated = Date()
//                smartCollection.type = .smart

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
    case unableToSaveCollection
    case filmNotFound
    case collectionNotFound
}
