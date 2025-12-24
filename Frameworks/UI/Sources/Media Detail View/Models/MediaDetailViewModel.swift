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
    var averageColor: Color
    var filmDisplay: FilmDisplay

    var feedback: Feedback? = nil

    var menuSections: [MenuSection] = []
    var cast: [PersonResponse]?
    var seasons: [AdditionalDetailsTVShow.SeasonResponse] = []
    var seasonsWatched = [AdditionalDetailsTVShow.SeasonResponse]()
    var trailer: AdditionalDetailsMovie.VideoResponse.Video?
    var genres: String?
    var releaseYear: String?
    var duration: String?

    @ObservationIgnored
    @Dependency(\.date.now) var now
    @ObservationIgnored
    @Dependency(\.movieProvider) var movieProvider
    @ObservationIgnored
    @Dependency(\.networkClient) var networkClient

    init(media: some DetailViewRepresentable) {
        @Dependency(\.imageLoader.cachedImage) var cachedImage
        self.averageColor = Color(cachedImage(media.posterPath)?.averageColor ?? UIColor(resource: .brightRed))
        self.filmDisplay = FilmDisplay(from: media)
    }

    @MainActor
    func loadInitialData() async {
       if let existingFilm = movieProvider.fetchFilm(filmDisplay.id) {
           feedback = existingFilm.feedback
            self.filmDisplay = FilmDisplay(from: existingFilm)
        }

        setMenuActions()
    }

    public func saveToLibraryIfNecessary() -> Film? {
        if let existingFilm = movieProvider.fetchFilm(filmDisplay.id) {
            existingFilm
        } else {
            try? movieProvider.saveFilmToLibrary(.init(filmDisplay, feedback: feedback))
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

        self.filmDisplay = FilmDisplay(from: cdFilm)
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

        self.filmDisplay = FilmDisplay(from: cdFilm)
    }

    public func addActivity(feedback: Feedback?) {
        guard let feedback else {
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

        self.filmDisplay = FilmDisplay(from: cdFilm)

        setMenuActions()
    }

    // FIXME: Would be nice to live in its own service
    public func getAdditionalDetailsTVShow() async {
        do {
            let endpoint = TMDBEndpoint.tvShowDetails(id: filmDisplay.id)
            let tvShowDetails: AdditionalDetailsTVShow = try await networkClient.request(endpoint)
            let genres = tvShowDetails.genres.map { $0.name }.joined(separator: ", ")
            let releasedSeasons = tvShowDetails.releasedSeasons()

            await MainActor.run {
                self.seasons = releasedSeasons
                self.genres = genres
            }

        } catch {
            print("⛔️ Error fetching additional details: \(error)")
        }
    }

    // FIXME: Would be nice to live in its own service
    public func getAdditionalDetailsMovie() async {
        do {
            let endpoint = TMDBEndpoint.movieDetails(id: filmDisplay.id)
            let movieDetails: AdditionalDetailsMovie = try await networkClient.request(endpoint)
            let genres = movieDetails.genres.map { $0.name }.joined(separator: ", ")

            do {
                try await MainActor.run {
                    self.trailer = try movieDetails.videos.trailer()
                    self.genres = genres
                    self.cast = Array(movieDetails.actorsOrderedByPopularity().prefix(10))
                    self.releaseYear = movieDetails.releaseYear
                    self.duration = movieDetails.formattedDuration
                }

            } catch {
                print("⛔️ No trailer: \(error)")
            }

        } catch {
            print("⛔️ Error fetching additional details: \(error)")
        }
    }

    // MARK: Menu Actions
    // FIXME: Would be nice to live away from this VM

    private func removeFromLibrary() {
        feedback = nil

        try? movieProvider.deleteFilm(filmDisplay.id)
        setMenuActions()
    }

    private func markAsWatched() {
        feedback = nil

        _ = try? movieProvider.saveFilmToLibrary(.init(filmDisplay, feedback: feedback))
        setMenuActions()
    }

    private func addToWatchList() {
        feedback = nil

        _ = try? movieProvider.saveFilmToWatchLater(self.filmDisplay)
        setMenuActions()
    }

    public func setMenuActions() {
        var sections: [MenuSection] = []

        var primaryActions: [MenuAction] = []
        var destructiveActions: [MenuAction] = []

        if let existingFilm = movieProvider.fetchFilm(filmDisplay.id) {
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
