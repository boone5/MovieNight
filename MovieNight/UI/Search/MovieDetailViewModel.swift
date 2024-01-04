//
//  MovieDetailViewModel.swift
//  MovieNight
//
//  Created by Boone on 1/1/24.
//

import CoreData
import Foundation

final class MovieDetailViewModel: ObservableObject {
    @Published var movie: MovieDetails

    private let provider: MovieProvider
    private let context: NSManagedObjectContext

    init(movie: MovieDetails? = nil, provider: MovieProvider) {
        self.provider = provider
        self.context = provider.viewContext

        if let movie, let existingMovieCopy = provider.exists(movie, in: context) {
            self.movie = existingMovieCopy
        } else {
            self.movie = MovieDetails(context: self.context)
        }
    }

    func save() throws {
        try provider.persist(in: context)
    }
}
