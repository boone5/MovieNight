//
//  MovieProvider.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import Dependencies
import Combine
import CoreData
import Foundation
import Models


public protocol MovieProviderClient {
    func save()
    func fetchFilm(_ id: Film.ID) -> Film?
    func fetchCollection(_ id: UUID) -> FilmCollection?
    func saveFilmToLibrary(_ request: FilmSaveRequest) throws(MovieError) -> Film
    func saveFilmToWatchLater(_ film: MediaItem) throws(MovieError) -> Film
    func deleteFilm(_ id: Film.ID) throws(MovieError)
    func prepareDefaultCollections() throws(MovieError)

    var eventPublisher: AnyPublisher<MovieProviderEvent, Never> { get }

    var container: NSPersistentContainer { get }
}

extension MovieProviderClient {
    /// Publisher that emits feedback updates only for a specific media ID,
    /// delivered on the main thread.
    public func feedbackPublisher(for id: MediaItem.ID) -> AnyPublisher<Feedback, Never> {
        eventPublisher
            .compactMap { event -> Feedback? in
                if case let .filmSaved(film) = event, film.id == id {
                    return film.feedback
                }
                if case let .filmDeleted(deletedID) = event, deletedID == id {
                    return nil
                }
                return nil
            }
            .removeDuplicates() // if Feedback: Equatable
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
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
