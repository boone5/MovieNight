//
//  MovieProvider.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import Dependencies
import CoreData
import Foundation
import Models


public protocol MovieProviderClient {
    func save()
    func fetchFilm(_ id: Film.ID) -> Film?
    func fetchCollection(_ id: UUID) -> FilmCollection?
    func saveFilmToLibrary(_ request: FilmSaveRequest) throws(MovieError) -> Film
    func saveFilmToWatchLater(_ film: DetailViewRepresentable) throws(MovieError) -> Film
    func deleteFilm(_ id: Film.ID) throws(MovieError)
    func deleteCollection(_ id: UUID) throws(MovieError)
    func renameCollection(_ id: UUID, to newTitle: String) throws(MovieError)
    func prepareDefaultCollections() throws(MovieError)
    func createCollection(name: String, type: CollectionType) throws(MovieError) -> FilmCollection
    func fetchAllCollections() -> [FilmCollection]
    func addFilmToCollection(filmId: Film.ID, collectionId: UUID) throws(MovieError)
    func removeFilmFromCollection(filmId: Film.ID, collectionId: UUID) throws(MovieError)

    var container: NSPersistentContainer { get }
}

private enum MovieProviderClientKey: DependencyKey {
    static let liveValue: MovieProviderClient = MovieProvider(inMemory: false)
    static let previewValue: MovieProviderClient = MovieProvider(inMemory: true)
}

public extension DependencyValues {
    var movieProvider: MovieProviderClient {
        get { self[MovieProviderClientKey.self] }
        set { self[MovieProviderClientKey.self] = newValue }
    }
}
