//
//  ImageLoader.swift
//  MovieNight
//
//  Created by Boone on 12/3/23.
//

import Networking
import Foundation
import UIKit

// https://www.andyibanez.com/posts/caching-content-with-nscache/
actor ImageLoader {
    // The key will be a String representation of the URL. The value will be the image object stored as Data.
    typealias CacheType = NSCache<NSString, NSData>

    private let networkManager: NetworkManager = NetworkManager()
    private var map: [String: LoaderStatus] = [:]

    private lazy var cache: CacheType = {
        let cache = CacheType()
        cache.countLimit = 100
        // 1024 bytes in a KB
        // 1024 KB in a MB
        // Multipled by 50 gives 50 MB or 52,428,800 bytes
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()

    /// Make a network request OR load an Image from the ImageCache. Function handles errors respectively.
    public func load(_ imgExtension: String?) async throws -> Data? {
        guard let imgExtension else { return nil }

        // 1) Check for outgoing task
        if let status = map[imgExtension] {
            switch status {
            case .inProgress(let task):
                print("⚠️ Awaiting outgoing task")
                let data = try await task.value

                print("✅ Outgoing Task finished loading")

                map[imgExtension] = nil

                return data
            }
        }

        // 2) Exists on Disk?
        if let imageData = getObject(forKey: imgExtension) {
            return imageData
        }

        // 3) Request image
        let task: Task<Data, Error> = Task {
            let data = try await self.networkManager.requestData(PosterEndpoint.poster(imgExtension))
            set(object: data, forKey: imgExtension)
            return data
        }
        
        map[imgExtension] = .inProgress(task)

        let data = try await task.value

        map[imgExtension] = nil

        return data
    }

    // Get from Cache
    private func getObject(forKey key: String?) -> Data? {
        print("⬇️ Fetching Image from Cache for key: \(String(describing: key))")

        guard let key else { return nil }

        return cache.object(forKey: key as NSString) as? Data
    }

    // Save to Cache
    private func set(object: Data, forKey key: String) {
        print("⬆️ Storing image in Cache for key: \(key)")
        cache.setObject(object as NSData, forKey: key as NSString)
    }

    private enum LoaderStatus {
        case inProgress(Task<Data, Error>)
    }
}
