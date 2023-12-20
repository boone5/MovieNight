//
//  SearchViewModel.swift
//  MovieNight
//
//  Created by Boone on 8/22/23.
//

import Combine
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var movieCells: [MovieResult?] = []
    @Published var state: LoadingState = .undefined

    private let movieService: MovieService
    private var cancellables: Set<AnyCancellable> = []

    init(movieService: MovieService = MovieService()) {
        self.movieService = movieService
    }

    // title has to be non-empty
    @MainActor
    func fetchMovies(for title: String) async {
        self.state = .loading

        movieService.fetchMovies(for: title)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("⛔️ Error: \(error)")
                }
            } receiveValue: { [weak self] movies in
                self?.movieCells = movies
                self?.state = .completed
            }
            .store(in: &cancellables)
    }
}

enum LoadingState {
    case undefined
    case loading
    case completed
}
