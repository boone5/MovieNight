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
    func load(_ imgExtension: String?, cache: ImageCache = .shared) async {
        guard let imgExtension else { return }

        if let imageData = cache.getObject(forKey: imgExtension) {
            self.data = imageData
            return
        }

        do {
            let data = try await networkManager.request(Data.self, PosterEndpoint.poster(imgExtension))

            cache.set(object: data, forKey: imgExtension)

            self.data = data

        } catch {
            print("⛔️ Error retrieving image data: \(error)")
        }
    }
}
