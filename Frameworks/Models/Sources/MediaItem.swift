//
//  MediaItem.swift
//  Frameworks
//
//  Created by Ayren King on 12/23/25.
//

import Foundation

/// A unified, UI-facing representation of any media content displayed in the app.
///
/// `MediaItem` is the canonical domain model used by views and view models to render
/// movies, TV shows, and people in a consistent way, regardless of where the data
/// originates from (network responses, persistence, or in-memory state).
///
/// ### Design
/// - Value type (`struct`) to ensure predictable equality and SwiftUI diffing
/// - Intentionally contains only the subset of fields required to drive UI
/// - Abstracted away from API and persistence-specific models
///
/// ### Sources
/// A `MediaItem` can be created from:
/// - `MediaResult` (TMDB search / discovery responses)
/// - `Film` (Core Data persistence)
///
/// ### Non-Goals
/// - Does **not** represent the full API response
/// - Does **not** include mutable or UI-derived state (e.g. poster data, colors)
/// - Does **not** perform network or persistence operations
///
/// This type should be constructed at feature boundaries and passed downstream
/// to views and view models. Business logic should operate on `MediaItem` instead
/// of API or Core Data models directly.
public struct MediaItem: Identifiable, Hashable {
    public let id: Int64
    public let mediaType: MediaType

    // MARK: - Shared Display Properties

    public let title: String
    public let originalTitle: String?
    public let overview: String?
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String?
    public let popularity: Double?
    public var feedback: Feedback?

    // MARK: - Type-Specific Data

    public let movie: MovieMetadata?
    public let tvShow: TVShowMetadata?
    public let person: PersonMetadata?

    public var comments: [Comment]?

    init(
        id: Int64,
        mediaType: MediaType,
        title: String,
        originalTitle: String? = nil,
        overview: String? = nil,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        releaseDate: String? = nil,
        popularity: Double? = nil,
        feedback: Feedback? = nil,
        movie: MovieMetadata? = nil,
        tvShow: TVShowMetadata? = nil,
        person: PersonMetadata? = nil,
        comments: [Comment]? = nil
    ) {
        self.id = id
        self.mediaType = mediaType
        self.title = title
        self.originalTitle = originalTitle
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.popularity = popularity
        self.feedback = feedback
        self.movie = movie
        self.tvShow = tvShow
        self.person = person
        self.comments = comments
    }
}

public struct MovieMetadata: Hashable {
    public let adult: Bool?
    public let genreIDs: [Int]?
    public let originalLanguage: String?
    public let video: Bool?
    public let voteAverage: Double?
    public let voteCount: Int64?
}

public struct TVShowMetadata: Hashable {
    public let adult: Bool?
    public let genreIDs: [Int]?
    public let originalLanguage: String?
    public let originCountries: [String]?
    public let voteAverage: Double?
    public let voteCount: Int64?
}

public struct PersonMetadata: Hashable {
    public let gender: PersonResponse.Gender?
    public let knownForDepartment: String?
    public let character: String?
    public let knownFor: [MediaItem]
}



extension MediaItem {
    public init(from result: MediaResult) {
        switch result {
        case .movie(let m):
            self.init(
                id: m.id,
                mediaType: m.mediaType,
                title: m.title,
                originalTitle: m.originalTitle,
                overview: m.overview,
                posterPath: m.posterPath,
                backdropPath: m.backdropPath,
                releaseDate: m.releaseDate,
                popularity: m.popularity,
                movie: MovieMetadata(
                    adult: m.adult,
                    genreIDs: m.genreIDs,
                    originalLanguage: m.originalLanguage,
                    video: m.video,
                    voteAverage: m.voteAverage,
                    voteCount: m.voteCount
                ),
            )

        case .tv(let t):
            self.init(
                id: t.id,
                mediaType: t.mediaType,
                title: t.title,
                originalTitle: t.originalTitle,
                overview: t.overview,
                posterPath: t.posterPath,
                backdropPath: t.backdropPath,
                releaseDate: t.releaseDate,
                popularity: t.popularity,
                tvShow: TVShowMetadata(
                    adult: t.adult,
                    genreIDs: t.genreIDs,
                    originalLanguage: t.originalLanguage,
                    originCountries: t.originCountries,
                    voteAverage: t.voteAverage,
                    voteCount: t.voteCount
                ),
            )

        case .person(let p):
            self.init(
                id: p.id,
                mediaType: p.mediaType,
                title: p.title,
                overview: p.overview,
                posterPath: p.posterPath,
                popularity: p.popularity,
                person: PersonMetadata(
                    gender: p.gender,
                    knownForDepartment: p.knownForDepartment,
                    character: p.character,
                    knownFor: p.knownFor?.compactMap(MediaItem.init) ?? []
                ),
            )
        }
    }
}

extension MediaItem {
    public init(from film: Film) {
        self.init(
            id: film.id,
            mediaType: film.mediaType,
            title: film.title ?? "-",
            overview: film.overview,
            posterPath: film.posterPath,
            releaseDate: film.releaseDate,
            feedback: film.feedback,
            comments: film.comments?.array as? [Comment],
        )
    }
}

extension MediaItem {

    /// Returns the release year extracted from `releaseDate`, if available.
    public var releaseYear: String? {
        releaseDate?.prefix(4).description
    }

    /// Indicates whether this media item represents a person.
    public var isPerson: Bool {
        mediaType == .person
    }

    /// Indicates whether this media item can be added to the user's library.
    public var isLibraryEligible: Bool {
        mediaType != .person
    }
}

