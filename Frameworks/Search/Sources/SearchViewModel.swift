//
//  SearchViewModel.swift
//  MovieNight
//
//  Created by Boone on 8/22/23.
//

import Combine
import Dependencies
import Models
import Networking
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var results: [ResponseType] = []

    private let debouncer = Debouncer(delay: 0.5)

    public var isLoading: Bool {
        state == .loading
    }

    private var state: LoadingState = .ready
    private var page: Int = 1
    @Dependency(\.networkClient) private var networkClient
    private var searchQuery: String = ""

    func search(query: String) {
        guard !query.isEmpty else {
            debouncer.cancel()
            results = []
            return
        }

        debouncer.run { [weak self] in
            await self?.fetchAllResults(for: query)
        }
    }

    func fetchAllResults(for query: String) async {
        self.searchQuery = query
        self.state = .loading
        self.page = 1

        do {
            let response: SearchResponse = try await networkClient.request(SearchEndpoint.multi(query: query, page: page))

            // this causes problems w/ pagination if cleanResults are less than 3
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
        guard self.state != .loadedAll, !results.isEmpty else { return }

        print("Loading more!")

        self.state = .fetching

        do {
            let response: SearchResponse = try await networkClient.request(SearchEndpoint.multi(query: searchQuery, page: page))

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
