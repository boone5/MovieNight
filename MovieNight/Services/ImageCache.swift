//
//  ImageCache.swift
//  MovieNight
//
//  Created by Boone on 12/3/23.
//

import Foundation

public class ImageCache {
    // The key will be a String representation of the URL. The value will be the image object stored as Data.
    typealias CacheType = NSCache<NSString, NSData>

    // MARK: Singleton
    // SwiftUI views are re-rendered so we don't want the cache to reset.
    static let shared = ImageCache()

    // Keeps the instantiation explicit to this file.
    private init() {}

    private lazy var cache: CacheType = {
        let cache = CacheType()
        cache.countLimit = 100
        // 52,428,800 bytes -> 50MB
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()

    // Get from Cache
    func getObject(forKey key: String?) -> Data? {
        guard let key else { return nil }
        
        return cache.object(forKey: key as NSString) as? Data
    }

    // Save to Cache
    func set(object: Data, forKey key: String) {
        print("⬆️ Storing image in Cache for key: \(key)")
        cache.setObject(object as NSData, forKey: key as NSString)
    }
}
