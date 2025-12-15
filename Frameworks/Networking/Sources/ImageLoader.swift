//
//  ImageLoader.swift
//  MovieNight
//
//  Created by Boone on 12/3/23.
//

import Dependencies
import Foundation
import SwiftUI

public struct ImageLoaderClient: Sendable {
    public var loadRaw: @Sendable (_ path: String?) async throws -> Data?
    public var loadImage: @Sendable (_ path: String?) async throws -> UIImage?
    public var cachedImage: @Sendable (_ path: String?) -> UIImage?
}

extension ImageLoaderClient: DependencyKey {
    public static let liveValue: ImageLoaderClient = {
        let loader = ImageLoaderActor()
        return ImageLoaderClient(
            loadRaw: { path in try await loader.loadRaw(path) },
            loadImage: { path in try await loader.loadImage(path) },
            cachedImage: { path in loader.cachedImage(path) }
        )
    }()

    public static let previewValue = ImageLoaderClient(
        loadRaw: { _ in Data() },
        loadImage: { _ in UIImage(systemName: "photo") },
        cachedImage: { _ in UIImage(systemName: "photo") }
    )

    public static let testValue = ImageLoaderClient(
        loadRaw: unimplemented("\(Self.self).loadRaw"),
        loadImage: unimplemented("\(Self.self).loadImage"),
        cachedImage: unimplemented("\(Self.self).cachedImage", placeholder: UIImage.checkmark)
    )
}

public extension DependencyValues {
    var imageLoader: ImageLoaderClient {
        get { self[ImageLoaderClient.self] }
        set { self[ImageLoaderClient.self] = newValue }
    }
}

private actor ImageLoaderActor {
    typealias UICache = NSCache<NSString, UIImage>

    @Dependency(\.logger.log) var log
    @Dependency(\.networkClient.requestData) var requestData

    /// Tracks currently-running requests to avoid duplicate fetches.
    private var inFlight: [String: LoaderStatus] = [:]

    /// Decoded Image cache (50 MB).
    private nonisolated(unsafe) let imageCache: UICache = {
        let cache = UICache()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
        return cache
    }()

    /// Loads image data from memory cache, disk cache, or network.
    ///
    /// Note: Data from this response is not cached. Use `loadImage(:_)` to cache the response.
    func loadRaw(_ path: String?) async throws -> Data? {
        guard let path else { return nil }

        // 1) Check for outgoing task
        if let status = inFlight[path], case let .inProgress(task) = status {
            log(.imageLoading, .debug, "⚠️ Awaiting outgoing task")
            let data = try await task.value
            log(.imageLoading, .debug, "✅ Outgoing Task finished loading")
            inFlight.removeValue(forKey: path)
            return data
        }

        // 2) Request image
        let task: Task<Data, Error> = Task {
            let data = try await requestData(PosterEndpoint.poster(path))
            return data
        }
        
        inFlight[path] = .inProgress(task)

        do {
            let data = try await task.value
            inFlight.removeValue(forKey: path)
            return data
        } catch {
            inFlight.removeValue(forKey: path)
            throw error
        }
    }

    /// Loads a fully decoded `UIImage`
    func loadImage(_ path: String?) async throws -> UIImage? {
        guard let path else { return nil }

        if let cached = imageCache.object(forKey: path as NSString) {
            return cached
        }

        guard let data = try await loadRaw(path), let image = UIImage(data: data) else { return nil }
        imageCache.setObject(image, forKey: path as NSString)
        return image
    }

    nonisolated func cachedImage(_ path: String?) -> UIImage? {
        guard let path else { return nil }
        return imageCache.object(forKey: path as NSString)
    }

    private enum LoaderStatus {
        case inProgress(Task<Data, Error>)
    }
}
