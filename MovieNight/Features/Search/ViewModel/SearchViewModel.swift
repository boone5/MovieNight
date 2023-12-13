//
//  SearchViewModel.swift
//  MovieNight
//
//  Created by Boone on 8/22/23.
//

import Combine
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var movieCells: [(MovieResult?, UIImage?)] = []
    private var cancellables: Set<AnyCancellable> = []

    let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    @MainActor
    func fetchMovieByTitle(_ title: String) async {
        guard let endpoint = URL(string: APIEndpoint.fetchMovieByTitle(title).path) else {
            return
        }

        var request = URLRequest(url: endpoint, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "X-RapidAPI-Key": "23a15db573mshe9f036d0688007bp1d8ea0jsn4c70d99f389b",
            "X-RapidAPI-Host": "moviesdatabase.p.rapidapi.com"
        ]

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .flatMap { movieResponse -> AnyPublisher<[(MovieResult?, UIImage?)], Error> in
                let thumbnailPublishers = movieResponse.results.compactMap { result -> AnyPublisher<(MovieResult?, UIImage?), Error>? in
                    guard let thumbnailString = result?.thumbnail?.url,
                          let thumbnailURL = URL(string: thumbnailString)
                    else {
                        print("⛔️ Unable to retrieve URL for Result: \(String(describing: result))")
                        print("Result is nil: \(result == nil)")
                        print("Thumbanil is nil: \(result?.thumbnail == nil)")
                        return nil
                    }

                    var request = URLRequest(url: thumbnailURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
                    request.httpMethod = "GET"

                    return URLSession.shared.dataTaskPublisher(for: request)
                        .map(\.data)
                        .tryMap { data in
                            guard let uiimage = UIImage(data: data) else {
                                throw URLError(.badServerResponse)
                            }
                            return (result, uiimage)
                        }
                        .retry(3)
                        .mapError { error in
                            print("⛔️ Error: \(error)")
                            return error
                        }
                        .eraseToAnyPublisher()
                }

                return Publishers.MergeMany(thumbnailPublishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // Handle completion
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("⛔️ Error: \(error)")
                }
            } receiveValue: { [weak self] movies in
                self?.movieCells = movies
            }
            .store(in: &cancellables)
    }
}
