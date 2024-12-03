//
//  MovieDataStore.swift
//  MovieNight
//
//  Created by Boone on 11/23/24.
//

import CoreData
import SwiftUI

class MovieDataStore: ObservableObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
    }

    @discardableResult
    public func filmExists(_ id: Int64) -> Bool {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        fetchRequest.fetchLimit = 1  // Limit to improve performance

        do {
            let count = try context.count(for: fetchRequest)
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

    public func saveFilm(_ film: ResponseType) {
        let movie = Movie(context: context)
        movie.title = film.title ?? ""
        movie.id = film.id
        movie.dateWatched = Date()
        movie.posterPath = film.posterPath
        save()
    }

    private func save() {
        do {
            try context.save()
        } catch {
            print("Error saving movie: \(error)")
        }
    }

    func fetchMoviesSortedByDateWatched() -> [Movie] {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()

        // Create a sort descriptor to sort by release date
        let sortDescriptor = NSSortDescriptor(key: "dateWatched", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            let movies = try context.fetch(fetchRequest)
            return movies
        } catch {
            print("Error fetching movies: \(error)")
            return []
        }
    }
}
