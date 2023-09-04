//
//  MovieViewModel.swift
//  MovieNight
//
//  Created by Boone on 8/22/23.
//

import SwiftUI

class MovieViewModel: ObservableObject {
    let networkManager: NetworkLayer
    @Published var movieResponse: MovieResponse = MovieResponse(page: 0, next: "", entries: 0, results: [])

    init(networkManager: NetworkLayer = NetworkLayer()) {
        self.networkManager = networkManager
    }

    @MainActor
    func fetchMovies() async {
        self.movieResponse = await networkManager.sendRequest()
    }
}
