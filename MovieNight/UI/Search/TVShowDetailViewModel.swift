//
//  TVShowDetailViewModel.swift
//  MovieNight
//
//  Created by Boone on 3/24/24.
//

import Foundation

@MainActor
class TVShowDetailViewModel: ObservableObject {
    public var tvShow: TVShowResponse

    @Published var recommendedTVShows: [TVShowResponse] = []
    @Published var voteAverage: Int = 0
    @Published var movieImage: Data?

    private var networkManager = NetworkManager()
    private var page: Int = 1

    init(tvShow: TVShowResponse) {
        self.tvShow = tvShow
    }

    public func fetchAddtionalDetails() async {
        do {
            let detailsData = try await networkManager.request(DetailsEndpoint.tvShowDetails(id: tvShow.id))
            let details = try JSONDecoder().decode(AdditionalDetailsTVShow.self, from: detailsData)

            self.convertWeightSystem(from: details.voteAverage)

            // Supports pagination so the decoded response is wrong currently
            let recommendedData = try await networkManager.request(RecommendedEndpoint.tvShows(id: tvShow.id, page: 1))
            let recommended = try JSONDecoder().decode(SearchResponse.self, from: recommendedData)

            recommended.results.forEach { type in
                switch type {
                case .tvShow(let tvShow):
                    self.recommendedTVShows.append(tvShow)
                default:
                    assertionFailure("Wrong type")
                }
            }

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

//            self.recommendedMovies = response.results

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
