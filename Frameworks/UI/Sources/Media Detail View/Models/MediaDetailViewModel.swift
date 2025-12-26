//
//  MediaDetailViewModel.swift
//  Frameworks
//
//  Created by Ayren King on 12/23/25.
//

import Dependencies
import Models
import Networking
import SwiftUI

@Observable
class MediaDetailViewModel {
    var media: MediaItem
    var averageColor: Color

    // UI state moved from view
    var showFullSummary: Bool = false
    var actionTapped: QuickAction? = nil
    var watchCount: Int = 0

    var menuSections: [MenuSection] = []

    var loadingState: LoadingState = .idle

    // Unified additional details per media type
    var details: MediaAdditionalDetails?

    @ObservationIgnored
    @Dependency(\.date.now) var now
    @ObservationIgnored
    @Dependency(\.movieProvider) var movieProvider
    @ObservationIgnored
    @Dependency(\.networkClient) var networkClient

    init(media: MediaItem) {
        @Dependency(\.imageLoader.cachedImage) var cachedImage
        self.averageColor = Color(cachedImage(media.posterPath)?.averageColor ?? UIColor(resource: .brightRed))
        self.media = media
    }

    @MainActor
    func loadInitialData() async {
        guard loadingState == .idle else { return }
        loadingState = .loading

        // Sync the display snapshot from library once at startup
        syncMediaFromLibrary()

        switch media.mediaType {
        case .movie:
            await getAdditionalDetailsMovie()
        case .tv:
            await getAdditionalDetailsTVShow()
        case .person:
            await getAdditionDetailsPerson()
        }

        setMenuActions()
        loadingState = .loaded
    }

    /// Hydrates the `media` snapshot from the saved library if present.
    /// Persons are not synced because they do not correspond to a Film record.
    private func syncMediaFromLibrary() {
        guard media.mediaType != .person else { return }
        if let existingFilm = movieProvider.fetchFilm(media.id) {
            media.feedback = existingFilm.feedback
            media.comments = MediaItem(from: existingFilm).comments
        }
    }

    public func saveToLibraryIfNecessary() -> Film? {
        if let existingFilm = movieProvider.fetchFilm(media.id) {
            existingFilm
        } else {
            try? movieProvider.saveFilmToLibrary(.init(media))
        }
    }

    public func markSeasonAsWatched(_ season: AdditionalDetailsTVShow.SeasonResponse) {
        let cdFilm = saveToLibraryIfNecessary()
        guard let cdFilm, let context = cdFilm.managedObjectContext else { return }

        let seasonCD = Season(context: context)
        seasonCD.id = Int64(season.id)
        seasonCD.title = season.name
        seasonCD.number = Int64(season.number)
        cdFilm.addToSeasonsWatched(seasonCD)

        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
        // Do not mutate `media` snapshot; keep the view stable.
        // If needed, derive lightweight UI state updates separately.
    }

    public func addComment(text: String) {
        let date = now
        let cdFilm = saveToLibraryIfNecessary()
        guard let cdFilm, let context = cdFilm.managedObjectContext else { return }

        let comment = Comment(context: context)
        comment.date = date
        comment.text = text
        cdFilm.addToComments(comment)

        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }

        // Update UI snapshot
        if media.comments == nil {
            media.comments = []
        }
        media.comments?.append(comment)
    }

    public func addActivity(feedback: Feedback?) {
        guard let feedback = media.feedback else {
            removeFromLibrary()
            // TODO: show confirmation
            return
        }

        let cdFilm = saveToLibraryIfNecessary()
        guard let cdFilm, let context = cdFilm.managedObjectContext else { return }
        cdFilm.feedback = feedback

        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }

        media.feedback = feedback
        setMenuActions()
    }

    public func getAdditionalDetailsTVShow() async {
        guard media.mediaType == .tv else { return }
        do {
            let tvShowDetails: AdditionalDetailsTVShow = try await networkClient.fetchTVShowDetails(media.id)
            let genres = tvShowDetails.genres.map { $0.name }.joined(separator: ", ")
            let releasedSeasons = tvShowDetails.releasedSeasons()
            // let cast = Array(tvShowDetails.orderedCast().prefix(10))

            await MainActor.run {
                self.details = .tv(.init(genres: genres, releaseYear: tvShowDetails.firstAirDate, duration: nil, cast: [], seasons: releasedSeasons, trailer: nil))
            }

        } catch {
            print("⛔️ Error fetching additional details: \(error)")
        }
    }

    public func getAdditionalDetailsMovie() async {
        guard media.mediaType == .movie else { return }
        do {
            let movieDetails: AdditionalDetailsMovie = try await networkClient.fetchMovieDetails(media.id)
            let genres = movieDetails.genres.map { $0.name }.joined(separator: ", ")
            let cast = Array(movieDetails.orderedCast().prefix(10))
            let trailer = try? movieDetails.videos.trailer()

            await MainActor.run {
                self.details = .movie(.init(genres: genres, releaseYear: movieDetails.releaseYear, duration: movieDetails.formattedDuration, cast: cast, trailer: trailer))
            }

        } catch {
            print("⛔️ Error fetching additional details: \(error)")
        }
    }

    public func getAdditionDetailsPerson() async {
        guard media.mediaType == .person else { return }
        do {
            let personDetails: AdditionalDetailsPerson = try await networkClient.fetchPersonDetails(media.id)
            await MainActor.run {
                self.details = .person(personDetails)
            }
        } catch {
            print("⛔️ Error fetching additional details: \(error)")
        }
    }

    // MARK: Menu Actions
    // FIXME: Would be nice to live away from this VM

    private func removeFromLibrary() {
        media.feedback = nil

        try? movieProvider.deleteFilm(media.id)
        setMenuActions()
    }

    private func markAsWatched() {
        media.feedback = nil

        _ = try? movieProvider.saveFilmToLibrary(.init(media))
        setMenuActions()
    }

    private func addToWatchList() {
        media.feedback = nil

        _ = try? movieProvider.saveFilmToWatchLater(self.media)
        setMenuActions()
    }

    public func setMenuActions() {
        var sections: [MenuSection] = []

        var primaryActions: [MenuAction] = []
        var destructiveActions: [MenuAction] = []

        // Person-specific actions
        if media.mediaType == .person {
            sections.append(
                MenuSection(
                    actions: [
                        MenuAction(
                            title: "Follow",
                            systemImage: "person.badge.plus",
                            role: .normal,
                            handler: { print("Follow person tapped") }
                        ),
                        MenuAction(
                            title: "Add to Favorites",
                            systemImage: "star",
                            role: .normal,
                            handler: { print("Add person to favorites tapped") }
                        ),
                        MenuAction(
                            title: "Share",
                            systemImage: "square.and.arrow.up",
                            role: .normal,
                            handler: { print("Share person tapped") }
                        )
                    ]
                )
            )
            // Assign and return early to avoid film/TV library actions
            menuSections = sections
            return
        }

        // Film/TV actions
        if let existingFilm = movieProvider.fetchFilm(media.id) {
            if existingFilm.isOnWatchList {
                primaryActions.append(
                    MenuAction(
                        title: "Remove from Watch List",
                        systemImage: "rectangle.stack.badge.minus",
                        role: .normal,
                        handler: { [weak self] in self?.removeFromLibrary() }
                    )
                )
            } else {
                destructiveActions.append(
                    MenuAction(
                        title: "Remove from Library",
                        systemImage: "trash",
                        role: .destructive,
                        handler: { [weak self] in self?.removeFromLibrary() }
                    )
                )
            }
        } else {
            primaryActions.append(
                MenuAction(
                    title: "Mark as Watched",
                    systemImage: "checkmark.circle",
                    role: .normal,
                    handler: { [weak self] in self?.markAsWatched() }
                )
            )

            primaryActions.append(
                MenuAction(
                    title: "Add to Watch List",
                    systemImage: "rectangle.stack.badge.plus",
                    role: .normal,
                    handler: { [weak self] in self?.addToWatchList() }
                )
            )
        }

        // Share section
        sections.append(
            MenuSection(
                actions: [
                    MenuAction(
                        title: "Share",
                        systemImage: "square.and.arrow.up",
                        role: .normal,
                        handler: { print("User action was tapped") }
                    )
                ]
            )
        )

        // Primary actions
        if !primaryActions.isEmpty {
            sections.append(MenuSection(actions: primaryActions))
        }

        // Destructive actions
        if !destructiveActions.isEmpty {
            sections.append(MenuSection(actions: destructiveActions))
        }

        menuSections = sections
    }

}

extension MediaDetailViewModel {
    enum MediaAdditionalDetails {
        case movie(MovieDetails)
        case tv(TVDetails)
        case person(AdditionalDetailsPerson)
    }

    struct MovieDetails {
        let genres: String?
        let releaseYear: String?
        let duration: String?
        let cast: [CastCredit]?
        let trailer: AdditionalDetailsMovie.VideoResponse.Video?
    }

    struct TVDetails {
        let genres: String?
        let releaseYear: String?
        let duration: String?
        let cast: [CastCredit]?
        let seasons: [AdditionalDetailsTVShow.SeasonResponse]
        let trailer: AdditionalDetailsMovie.VideoResponse.Video?
    }

    struct MenuSection: Identifiable {
        let id = UUID()
        let actions: [MenuAction]
    }

    struct MenuAction: Identifiable {
        enum Role {
            case normal
            case destructive
        }

        let id = UUID()
        let title: String
        let systemImage: String
        let role: Role
        let handler: () -> Void
    }
}
