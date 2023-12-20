//
//  ThumbnailViewModel.swift
//  MovieNight
//
//  Created by Boone on 12/3/23.
//

import Foundation

final class ThumbnailViewModel: ObservableObject {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    @Published private(set) var data: Data?

    /// Make a network request OR load an Image from the ImageCache. Function handles errors respectively.
    @MainActor
    func load(_ imgURL: String?, cache: ImageCache = .shared) async {
        guard let url = imgURL else { return }

        if let imageData = cache.getObject(forKey: url) {
            self.data = imageData
            return
        }

        do {
            let data = try await networkManager.request(.fetchMovieThumbnail(url))

            cache.set(object: data, forKey: url)

            self.data = data

        } catch(let error) {
            if let error = error as? APIError {
                // MARK: LOG
                // This is an area where I could log an event with the error we receive back.
                print(error.description)
            }
            print(APIError.unknownError(error).description)
        }
    }
}
