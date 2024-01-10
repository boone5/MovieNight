//
//  SearchViewModel.swift
//  MovieNight
//
//  Created by Boone on 8/22/23.
//

import Combine
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var state: LoadingState = .ready
    @Published var currentTitle: String = ""
    @Published var movieDetails: [MovieResponseTMDB.Details] = [MovieResponseTMDB.Details]()

    public var isLoading: Bool {
        state == .loading
    }

    private var page: Int = 1
    private var networkManager = NetworkManager()

    func fetchMovieDetails(for title: String) async {
        self.currentTitle = title
        self.state = .loading

        do {
            let data = try await networkManager.request(SearchEndpoint.search(title: title, page: page))

            let response = try JSONDecoder().decode(MovieResponseTMDB.self, from: data)

            self.movieDetails = response.results

            self.page += 1
            self.state = (page > response.totalPages) ? .loadedAll : .ready

        } catch {
            if let error = error as? DecodingError {
                print("⛔️ Decoding error: \(error)")
            } else {
                print("⛔️ Network error: \(error)")
            }
        }
    }

    func loadMore() async {
        self.state = .fetching

        do {
            let data = try await networkManager.request(SearchEndpoint.search(title: currentTitle, page: page))

            let response = try JSONDecoder().decode(MovieResponseTMDB.self, from: data)

            self.movieDetails.append(contentsOf: response.results)

            self.page += 1
            self.state = (page > response.totalPages) ? .loadedAll : .ready

        } catch {
            if let error = error as? DecodingError {
                print("⛔️ Decoding error: \(error)")
            } else {
                print("⛔️ Network error: \(error)")
            }
        }
    }

    public func shouldLoadMore(comparing movie: MovieResponseTMDB.Details) -> Bool {
        let count = movieDetails.count - 3

        return self.movieDetails[count].id == movie.id
    }
}

enum LoadingState {
    case ready
    case fetching
    case loading
    case loadedAll
}
