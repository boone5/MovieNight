//
//  SearchViewModel.swift
//  MovieNight
//
//  Created by Boone on 8/22/23.
//

import Combine
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var movie: Movie?
    @Published var state: LoadingState = .undefined

    private var pageIsAvailable: Bool {
        return false
    }

    public var isLoading: Bool {
        state == .loading
    }

    public var isFetching: Bool {
        state == .fetching
    }

    private var page: Int = 1
    private var currentTitle: String = ""

    @MainActor
    func fetchMovieDetails(for title: String) async {
        self.state = .loading

        do {
            let data = try await NetworkManager.shared.request(Movie.self, SearchEndpoint.search(title: title))

            let decoded = try JSONDecoder().decode(Movie.self, from: data)

            self.movie = decoded
            self.state = .completed
        } catch {
            if let error = error as? DecodingError {
                print("⛔️ Decoding error: \(error)")
            } else {
                print("⛔️ Network error: \(error)")
            }
        }
    }

    public func shouldRequestNewPage(comparing movie: MovieResultTMDB) -> Bool {
        self.pageIsAvailable && (self.movie?.results.last?.id == movie.id)
    }
}

enum LoadingState {
    case undefined
    case fetching
    case loading
    case completed
}
