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
    @Published var movieDetails: [SearchResponse.Movie] = [SearchResponse.Movie]()

    public var isLoading: Bool {
        state == .loading
    }

    private var page: Int = 1
    private var networkManager = NetworkManager()
    private var searchQuery: String = ""

    func fetchMovieDetails(for title: String) async {
        self.searchQuery = title
        self.state = .loading
        self.page = 1

        do {
            let data = try await networkManager.request(SearchEndpoint.search(title: title, page: page))

            let response = try JSONDecoder().decode(SearchResponse.self, from: data)

            self.movieDetails = response.results
            self.page += 1
            self.state = (page >= response.totalPages) ? .loadedAll : .ready

        } catch let error as DecodingError {
            print("⛔️ Decoding error: \(error)")
        } catch {
            print("⛔️ Network error: \(error)")
        }
    }

    func loadMore() async {
        self.state = .fetching

        do {
            let data = try await networkManager.request(SearchEndpoint.search(title: searchQuery, page: page))

            let response = try JSONDecoder().decode(SearchResponse.self, from: data)

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

    public func shouldLoadMore() -> Bool {
        guard self.state != .loadedAll, self.state != .fetching else {
            print("Can't load more: \(self.state)")
            return false
        }

        print("Loading more!")

        return true
    }
}
