//
//  MovieDetailViewModel.swift
//  MovieNight
//
//  Created by Boone on 1/23/24.
//

import Foundation

@MainActor
class MovieDetailViewModel: ObservableObject {
    @Published var recommendedMovies: [SearchResponse.Movie] = []
    @Published var details: MovieDetails?

    @Published var voteAverage: Int = 0
    @Published var didLeaveReview: Bool = false
    @Published var userRating: Int16 = 0

    private var networkManager = NetworkManager()

    private var page: Int = 1

    public func fetchAdditionalDetails(_ id: Int64) async {
        await self.fetchMovieDetails(id: id)
        await self.fetchRecommendedMovies(id: id)

        if let movie = MovieProvider.shared.exists(id: id), movie.userRating != 0 {
            self.didLeaveReview = true
            self.userRating = movie.userRating
        }
    }

    private func fetchMovieDetails(id: Int64) async {
        do {
            let data = try await networkManager.request(DetailsEndpoint.movieDetails(id: id))

            let response = try JSONDecoder().decode(MovieDetails.self, from: data)

            self.details = response

            self.convertWeightSystem(from: response.voteAverage)

        } catch let error as DecodingError {
            print("⛔️ Decoding error: \(error)")
        } catch {
            print("⛔️ Network error: \(error)")
        }
    }

    private func fetchRecommendedMovies(id: Int64) async {
        do {
            let data = try await networkManager.request(RecommendedEndpoint.recommendedMovies(id: id, page: 1))

            let response = try JSONDecoder().decode(SearchResponse.self, from: data)

            self.recommendedMovies = response.results

        } catch let error as DecodingError {
            print("⛔️ Decoding error: \(error)")
        } catch {
            print("⛔️ Network error: \(error)")
        }
    }

    private func fetchCast(id: Int64) async {
        do {
            let data = try await networkManager.request(CastEndpoint.movieCredits(id: id))

            #warning("TODO: Create new model for cast response")
            let response = try JSONDecoder().decode(SearchResponse.self, from: data)

            self.recommendedMovies = response.results

        } catch let error as DecodingError {
            print("⛔️ Decoding error: \(error)")
        } catch {
            print("⛔️ Network error: \(error)")
        }
    }

    private func convertWeightSystem(from avg: Double) {
        print(avg)
        switch avg {
        case 0..<3:
            self.voteAverage = 1
        case 3..<5:
            self.voteAverage = 2
        case 5..<7:
            self.voteAverage = 3
        case 7..<9:
            self.voteAverage = 4
        case 9..<10:
            self.voteAverage = 5
        default:
            break
        }
    }
}
