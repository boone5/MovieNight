//
//  MovieService.swift
//  MovieNight
//
//  Created by Boone on 12/16/23.
//

import Combine
import Foundation

class MovieService {
    func fetchMovies(for title: String) -> AnyPublisher<[MovieResult], Error>{
        let endpoint = APIEndpoint.movies(title)

        guard let url = endpoint.url else {
            return Fail(error: APIError.badURL).eraseToAnyPublisher()
        }

        let request = NetworkManager.shared.createRequest(url: url)

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw APIError.networkError(URLError(.badServerResponse))
                }
                
                return data
            }
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .flatMap { movieResponse in
                return self.loadThumbnails(for: movieResponse.results)
            }
            .mapError { error in
                if let error = error as? DecodingError {
                    return APIError.decodingError(error)
                } else {
                    return APIError.unknownError(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func loadThumbnails(for results: [MovieResult]) -> AnyPublisher<[MovieResult], Error> {
        let thumbnailPublishers = results
            .compactMap { result -> AnyPublisher<MovieResult, Error>? in
                guard let urlString = result.thumbnail?.url,
                      let url = URL(string: urlString)
                else {
                    return nil
                }

                var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
                request.httpMethod = "GET"

                // maybe add error handling before we get the data?
                return URLSession.shared.dataTaskPublisher(for: request)
                    .tryMap { imgData, response in
                        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                            throw APIError.networkError(URLError(.badServerResponse))
                        }

                        return self.refineMovieModel(with: result, imageData: imgData)
                    }
                    .mapError { error in
                        return APIError.badURL
                    }
                    .eraseToAnyPublisher()
            }

        return Publishers.MergeMany(thumbnailPublishers)
            .collect()
            .eraseToAnyPublisher()
    }

    // expand on this as we utilize more properties
    private func refineMovieModel(with movieResult: MovieResult, imageData: Data) -> MovieResult {
        MovieResult(
            thumbnail: MovieResult.Thumbail(imgData: imageData),
            releaseYear: MovieResult.ReleaseYear(endYear: movieResult.releaseYear?.endYear, year: movieResult.releaseYear?.year),
            titleText: MovieResult.TitleText(text: movieResult.titleText?.text)
        )
    }
}
