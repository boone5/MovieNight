//
//  SearchViewModel.swift
//  MovieNight
//
//  Created by Boone on 8/22/23.
//

import Combine
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var results: [ResponseType] = []

    public var isLoading: Bool {
        state == .loading
    }

    private var state: LoadingState = .ready
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
            
            let cleanResults = response.results.filter { $0 != .empty }

            self.page += 1
            self.state = (page > response.totalPages) ? .loadedAll : .ready

            await MainActor.run {
                self.results = cleanResults
            }

        } catch let error as DecodingError {
            print("⛔️ Decoding error: \(error)")
        } catch {
            print("⛔️ Network error: \(error)")
        }
    }

    func loadMore() async {
        guard self.state != .loadedAll else { return }

        print("Loading more!")

        self.state = .fetching

        do {
            let data = try await networkManager.request(SearchEndpoint.multi(query: searchQuery, page: page))
            let response = try JSONDecoder().decode(SearchResponse.self, from: data)

            let cleanResults = response.results.filter { $0 != .empty }

            self.page += 1
            self.state = (page > response.totalPages) ? .loadedAll : .ready

            await MainActor.run {
                self.results.append(contentsOf: cleanResults)
            }

        } catch let error as DecodingError {
            print("⛔️ Decoding error: \(error)")
        } catch {
            print("⛔️ Network error: \(error)")
        }
    }
}
