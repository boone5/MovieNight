//
//  SearchViewModel.swift
//  MovieNight
//
//  Created by Boone on 8/22/23.
//

import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var movieResponse: MovieResponse = MovieResponse(page: 0, next: "", entries: 0, results: [])
    
    let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    @MainActor
    func fetchMovieByTitle(_ title: String) async {
        #if RELEASE
        do {
            let data = try await networkManager.request(.fetchMovieByTitle(title))

            self.movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
        } catch {
            print(error)
        }
        #elseif DEBUG
        self.movieResponse = MovieMocks().generateMovies(count: 10)
        #endif
    }
}
