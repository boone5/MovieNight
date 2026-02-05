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
                log(.movieProvider, .info, "✅ Successfully saved new context.")
            } catch {
                log(.movieProvider, .error, "⛔️ Error saving context: \(error.localizedDescription)")
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
        movie.feedback = request.film.feedback

        if let comment = request.comment {
            movie.addToComments(comment)
        }

        // Add to Recently Watched collection, creating it if it doesn't exist
        let recentlyWatchedCollection: FilmCollection
        if let existing = fetchCollection(FilmCollection.recentlyWatchedID) {
            recentlyWatchedCollection = existing
        } else {
            recentlyWatchedCollection = FilmCollection(context: container.viewContext)
            recentlyWatchedCollection.id = FilmCollection.recentlyWatchedID
            recentlyWatchedCollection.title = "Recently Watched"
            recentlyWatchedCollection.imageName = "movieclapper"
            recentlyWatchedCollection.dateCreated = Date()
            recentlyWatchedCollection.type = .custom
        }
        recentlyWatchedCollection.addToFilms(movie)
        movie.addToCollections(recentlyWatchedCollection)

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

    public func fetchAllCollections() -> [FilmCollection] {
        let request: NSFetchRequest<FilmCollection> = FilmCollection.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FilmCollection.dateCreated, ascending: true)]

        do {
            return try container.viewContext.fetch(request)
        } catch {
            log(.movieProvider, .error, "⛔️ Error fetching collections: \(error)")
            return []
        }
    }

    public func addFilmToCollection(filmId: Film.ID, collectionId: UUID) throws(MovieError) {
        guard let film = fetchFilm(filmId) else {
            throw MovieError.filmNotFound
        }

        guard let collection = fetchCollection(collectionId) else {
            throw MovieError.collectionNotFound
        }

        film.addToCollections(collection)
        save()
    }

    public func removeFilmFromCollection(filmId: Film.ID, collectionId: UUID) throws(MovieError) {
        guard let film = fetchFilm(filmId) else {
            throw MovieError.filmNotFound
        }

        guard let collection = fetchCollection(collectionId) else {
            throw MovieError.collectionNotFound
        }

        film.removeFromCollections(collection)
        save()
    }

    public func updateFilmOrder(filmIds: [Film.ID], inCollection collectionId: UUID) throws(MovieError) {
        guard let collection = fetchCollection(collectionId) else {
            throw MovieError.collectionNotFound
        }
        let orderedFilms = filmIds.compactMap { fetchFilm($0) }
        collection.films = NSOrderedSet(array: orderedFilms)
        save()
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

// MARK: Debug Methods

#if DEBUG
extension MovieProvider {
    /// Loads default Collections into Core Data (for debugging purposes)
    public func prepareDefaultCollections() throws(MovieError) {
        // Get the managed object context from your Core Data stack
        let context = container.viewContext
        let rankedListID = FilmCollection.rankedListID
        let customListID = FilmCollection.customListID
        var didAddCollections = false

        do {
            let posterPaths = [
                "/jNsttCWZyPtW66MjhUozBzVsRb7.jpg",
                "/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg",
                "/d5NXSklXo0qyIYkgV94XAgMIckC.jpg",
                "/rCzpDGLbOoPwLjy3OAm5NUPOTrC.jpg",
                "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
                "/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg",
                "/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg",
                "/nBNZadXqJSdt05SHLqgT0HuC5Gm.jpg",
                "/kqjL17yufvn9OVLyXYpvtyrFfak.jpg",
                "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg"
            ]

            let filmTitles = [
                "The Shawshank Redemption",
                "The Godfather",
                "The Dark Knight",
                "Pulp Fiction",
                "Fight Club",
                "Inception",
                "The Matrix",
                "Goodfellas",
                "Se7en",
                "The Silence of the Lambs"
            ]

            if self.fetchCollection(rankedListID) == nil {
                // Create a ranked collection with films
                let rankedCollection = FilmCollection(context: context)
                rankedCollection.id = rankedListID
                rankedCollection.title = "Top 10 Films"
                rankedCollection.dateCreated = Date()
                rankedCollection.type = .ranked

                for i in 0..<10 {
                    let film = Film(context: context)
                    film.id = Int64(1000 + i)
                    film.title = filmTitles[i]
                    film.posterPath = posterPaths[i]
                    film.releaseDate = "199\(i)-01-01"
                    film.addToCollections(rankedCollection)
                }

                didAddCollections = true
            }

            if self.fetchCollection(customListID) == nil {
                // Create a custom collection with films
                let customCollection = FilmCollection(context: context)
                customCollection.id = customListID
                customCollection.title = "My Favorites"
                customCollection.dateCreated = Date()
                customCollection.type = .custom

                for i in 0..<5 {
                    let film = Film(context: context)
                    film.id = Int64(2000 + i)
                    film.title = filmTitles[i]
                    film.posterPath = posterPaths[i]
                    film.releaseDate = "200\(i)-01-01"
                    film.addToCollections(customCollection)
                }

                didAddCollections = true
            }

            if didAddCollections {
                try context.save()
                log(.movieProvider, .info, "✅ Default collections added!")
            } else {
                log(.movieProvider, .info, "🤝 Default collections already seeded.")
            }

        } catch {
            log(.movieProvider, .error, "⛔️ Error preloading default data: \(error)")
        }
    }
}
#endif
