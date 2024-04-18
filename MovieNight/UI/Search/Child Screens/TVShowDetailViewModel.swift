//
//  TVShowDetailViewModel.swift
//  MovieNight
//
//  Created by Boone on 3/24/24.
//

import Foundation

@MainActor
class TVShowDetailViewModel: ObservableObject {
    @Published var tvShow: AdditionalDetailsTVShow?
    @Published var recommendedTVShows: [TVShowResponse] = []
    @Published var voteAverage: Int = 0

    private var networkManager = NetworkManager()

    public func fetchAddtionalDetails(_ id: Int64) async {
        do {
            async let detailsData = try await networkManager.request(DetailsEndpoint.tvShowDetails(id: id))
            async let recommendedData = try await networkManager.request(RecommendedEndpoint.tvShows(id: id, page: 1))
//            let castData = try await networkManager.request(CastEndpoint.movieCredits(id: id))

            let details = try JSONDecoder().decode(AdditionalDetailsTVShow.self, from: await detailsData)

            print(details)
            
            let recommended = try JSONDecoder().decode(SearchResponse.self, from: await recommendedData)
//            let cast = try JSONDecoder().decode(SearchResponse.self, from: await castData)

            self.tvShow = details
            self.convertWeightSystem(from: details.voteAverage)

            recommended.results.forEach { tvShow in
                if case let .tvShow(tvShow) = tvShow {
                    self.recommendedTVShows.append(tvShow)
                }
            }

        } catch let error as DecodingError {
            print("⛔️ Decoding error: \(error)")
        } catch {
            print("⛔️ Network error: \(error)")
        }
    }

    public func fetchPoster(_ imgExtension: String?, imageLoader: ImageLoader) async -> Data? {
        guard let imgExtension else { return nil }

        do {
            return try await imageLoader.load(imgExtension)
        } catch {
            print("⛔️ Error fetching image: \(error)")
            return nil
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
