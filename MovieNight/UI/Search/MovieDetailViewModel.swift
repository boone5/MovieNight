//
//  MovieDetailViewModel.swift
//  MovieNight
//
//  Created by Boone on 1/23/24.
//

import Foundation

@MainActor
class MovieDetailViewModel: ObservableObject {
    @Published var details: DetailViewRepresentable
    @Published var recommendedMovies: [MovieResponseTMDB.Details] = []
    @Published var state: LoadingState = .ready

    @Published var voteAverage: Int = 0
    @Published var didLeaveReview: Bool = false

    private var movieActor: MovieActor = MovieActor()
    private var networkManager = NetworkManager()

    private var page: Int = 1

    init(details: DetailViewRepresentable) {
        self.details = details

        setUpView()

        Task {
            await movieActor.setMovieDetails(details)
        }
    }

    public func fetchRecommendedMovies() async {
        guard let movieDetails = await movieActor.getMovie() else { return }

        do {
            let data = try await networkManager.request(RecommendedEndpoint.recommendedMovies(movieID: movieDetails.id, page: page))

            let response = try JSONDecoder().decode(MovieResponseTMDB.self, from: data)

            self.recommendedMovies = response.results
            self.state = (page > response.totalPages) ? .loadedAll : .ready

        } catch let error as DecodingError {
            print("⛔️ Decoding error: \(error)")
        } catch {
            print("⛔️ Network error: \(error)")
        }
    }
    
    public func getImageData() -> Data? {
        if let cdModel = details as? Details_CD, let imgData = cdModel.posterData {
            return imgData
        } else {
            return ImageCache.shared.getObject(forKey: details.posterPath)
        }
    }

    private func setUpView() {
        self.getRating()
        self.convertWeightSystem(from: details.voteAverage)
    }

    private func getRating() {
        // 1) User has left a rating
        if details.userRating != 0 {
            self.didLeaveReview = true
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
