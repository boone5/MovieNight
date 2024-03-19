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
    @Published var movieDetails: [ResponseType] = [ResponseType]()

    public var isLoading: Bool {
        state == .loading
    }

    private var page: Int = 1
    private var networkManager = NetworkManager()
    private var searchQuery: String = ""

    func fetchAllResults(for query: String) async {
        self.searchQuery = query
        self.state = .loading
        self.page = 1

        do {
            let data = try await networkManager.request(SearchEndpoint.multi(query: query, page: page))
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
        guard !self.movieDetails.isEmpty else { return }

        print("Loading more!")

        self.state = .fetching

        do {
            let data = try await networkManager.request(SearchEndpoint.multi(query: searchQuery, page: page))
            let response = try JSONDecoder().decode(SearchResponse.self, from: data)

            self.movieDetails.append(contentsOf: response.results)

            self.page += 1
            self.state = (page > response.totalPages) ? .loadedAll : .ready

        } catch let error as DecodingError {
            print("⛔️ Decoding error: \(error)")
        } catch {
            print("⛔️ Network error: \(error)")
        }
    }
}
