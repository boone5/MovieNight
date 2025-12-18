//
//  FilmDetailView.swift
//  MovieNight
//
//  Created by Boone on 10/1/24.
//

import CoreData
import Dependencies
import Models
import Networking
import SwiftUI
import YouTubePlayerKit

// MARK: Preview

#Preview {
    @Previewable @Namespace var namespace

    let film: ResponseType = ResponseType.movie(MovieResponse())
//    let film: ResponseType = ResponseType.tvShow(TVShowResponse())

    FilmDetailView(film: film, navigationTransitionConfig: .init(namespace: namespace, source: film))
}

// MARK: FilmDetailView

public struct FilmDetailView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel: FilmDetailView.ViewModel
    let navigationTransitionConfig: NavigationTransitionConfiguration<Film.ID>
    let posterSize: CGSize

    @State private var actionTapped: QuickAction?
    @State private var watchCount = 0

    public init(
        film: some DetailViewRepresentable,
        navigationTransitionConfig: NavigationTransitionConfiguration<Film.ID>,
    ) {
        _viewModel = StateObject(wrappedValue: FilmDetailView.ViewModel(film: film))
        self.navigationTransitionConfig = navigationTransitionConfig

        let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.size ?? .zero
        self.posterSize = CGSize(width: size.width / 1.5, height: size.height / 2.4)
    }

    var averageColor: Color {
        viewModel.averageColor
    }

    @State var postion: ScrollPosition = .init()

    public var body: some View {
        ScrollView(
            .vertical,
            showsIndicators: true
        ) {
            VStack(alignment: .center, spacing: 30) {
                headerView

                // MARK: TODO
                // - Add gloss finish
                PosterView(
                    imagePath: viewModel.filmDisplay.posterPath,
                    size: posterSize,
                    filmID: viewModel.filmDisplay.id
                )
                .shadow(radius: 6, y: 3)
                .shimmyingEffect()

                VStack(alignment: .center, spacing: 5) {
                    Text(viewModel.filmDisplay.title ?? "")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    Text(viewModel.genres ?? "-")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))

                    Text([viewModel.releaseYear, viewModel.duration].compactMap { $0 }.joined(separator: " · "))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                }


                FeedbackButtons(
                    isLiked: $viewModel.isLiked,
                    isLoved: $viewModel.isLoved,
                    isDisliked: $viewModel.isDisliked,
                    averageColor: viewModel.averageColor,
                    didAddActivity: { isLiked, isLoved, isDisliked in
                        viewModel.addActivity(isLiked: isLiked, isLoved: isLoved, isDisliked: isDisliked)
                    }
                )

                // TODO: Add "See more" button
                if let summary = viewModel.filmDisplay.overview {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Summary")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)

                        Text(summary)
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(averageColor.opacity(0.4))
                    .cornerRadius(12)
                }

                CommentPromptView(
                    averageColor: viewModel.averageColor,
                    comments: viewModel.filmDisplay.comments,
                    didTapSave: { comment in
                        viewModel.addComment(text: comment)
                    }
                )

                QuickActionsView(
                    mediaType: viewModel.filmDisplay.mediaType,
                    averageColor: viewModel.averageColor,
                    actionTapped: $actionTapped
                )

                if let actionTapped {
                    switch actionTapped {
                    case .collection:
                        ActionView(averageColor: averageColor) {
                            HStack {
                                Text(actionTapped.longTitle)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)

                                Spacer()

                                Label {
                                    Text("Add a collection")
                                        .font(.system(size: 14))
                                } icon: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14))
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 8)
                                .background(averageColor.opacity(0.4))
                                .cornerRadius(12)
                            }
                        }
                    case .location:
                        WatchedAtView(averageColor: viewModel.averageColor)
                    case .watchCount:
                        ActionView(averageColor: averageColor) {
                            HStack(spacing: 0) {
                                Text(actionTapped.longTitle + " \(watchCount) times")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)

                                Spacer()

                                CustomStepper(steps: 10, startStep: $watchCount)
                            }
                            .padding(.vertical, 10)
                        }
                    case .watchedWith:
                        ActionView(averageColor: averageColor) {
                            Text(actionTapped.longTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    case .occasion:
                        ActionView(averageColor: averageColor) {
                            Text(actionTapped.longTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    case .seasonsWatched:
                        ActionView(averageColor: averageColor) {
                            Text(actionTapped.longTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    case .favoriteSeason:
                        ActionView(averageColor: averageColor) {
                            Text(actionTapped.longTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    case .favoriteEpisode:
                        ActionView(averageColor: averageColor) {
                            Text(actionTapped.longTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }

                // V2 w/ Social Features
//                    ParticipantsView(averageColor: viewModel.averageColor)
//                        .padding(.top, 30)

                if case .tvShow = viewModel.filmDisplay.mediaType {
                    SeasonsScrollView(viewModel: viewModel)
                }

                if let cast = viewModel.cast {
                    CastScrollView(averageColor: viewModel.averageColor, cast: cast)
                }

                if let trailer = viewModel.trailer, let key = trailer.key {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Trailer")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)

                        TrailerView(videoID: key)
                    }
                    .padding(20)
                    .background(averageColor.opacity(0.4))
                    .cornerRadius(12)
                }

                Spacer()
            }
            .padding(.vertical, 80)
            .padding(.horizontal, 20)
        }
        .background {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(
                    LinearGradient(
                        colors: [viewModel.averageColor, .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .task(id: "loadData") {
            await viewModel.loadInitialData()
            if viewModel.filmDisplay.mediaType == .movie {
                await viewModel.getAdditionalDetailsMovie()
            } else {
                await viewModel.getAdditionalDetailsTVShow()
            }
        }
        .zoomTransition(configuration: navigationTransitionConfig)
    }

    @MainActor
    var headerView: some View {
        HStack {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundStyle(.white)
                .padding(10)
                .background {
                    Circle()
                        .foregroundStyle(Color(uiColor: .white).opacity(0.2))
                }
                .contentShape(.circle)
                .onTapGesture {
                    dismiss()
                }

            Spacer()

            ButtonWithSourceView(menu: $viewModel.menuActions)
                .padding(6)
                .background {
                    Circle()
                        .foregroundStyle(Color(uiColor: .white).opacity(0.2))
                }
        }
    }

    // MARK: SeasonsScrollView

    struct SeasonsScrollView: View {
        @ObservedObject var viewModel: FilmDetailView.ViewModel

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Seasons Watched")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.seasons, id: \.id) { season in
                            SeasonPosterView(
                                posterPath: season.posterPath,
                                seasonNum: season.number,
                                averageColor: viewModel.averageColor
                            )
                        }
                    }
                    .padding([.horizontal], 30)
                }
                .scrollIndicators(.hidden)
                .padding([.horizontal], -30)
            }
            .padding(20)
            .background(viewModel.averageColor.opacity(0.4))
            .cornerRadius(12)
        }
    }
}

// MARK: ViewModel

extension FilmDetailView {
    class ViewModel: ObservableObject {
        @Published var averageColor: Color
        @Published var filmDisplay: FilmDisplay

        @Published var isLiked: Bool = false
        @Published var isLoved: Bool = false
        @Published var isDisliked: Bool = false

        @Published var menuActions: [UIMenu] = []
        @Published var cast: [ActorResponse.Actor]?
        @Published var seasons: [AdditionalDetailsTVShow.SeasonResponse] = []
        @Published var seasonsWatched = [AdditionalDetailsTVShow.SeasonResponse]()
        @Published var trailer: AdditionalDetailsMovie.VideoResponse.Video?
        @Published var genres: String?
        @Published var releaseYear: String?
        @Published var duration: String?

        @Dependency(\.date.now) var now
        @Dependency(\.movieProvider) var movieProvider
        @Dependency(\.networkClient) var networkClient

        init(film: some DetailViewRepresentable) {
            @Dependency(\.imageLoader.cachedImage) var cachedImage
            self.averageColor = Color(cachedImage(film.posterPath)?.averageColor ?? UIColor(resource: .brightRed))
            self.filmDisplay = FilmDisplay(from: film)
        }

        @MainActor
        func loadInitialData() async {
           if let existingFilm = movieProvider.fetchFilm(filmDisplay.id) {
                isLiked = existingFilm.isLiked
                isLoved = existingFilm.isLoved
                isDisliked = existingFilm.isDisliked
                self.filmDisplay = FilmDisplay(from: existingFilm)
            }

            setMenuActions()
        }

        public func saveToLibraryIfNecessary() -> Film? {
            if let existingFilm = movieProvider.fetchFilm(filmDisplay.id) {
                existingFilm
            } else {
                try? movieProvider.saveFilmToLibrary(
                    .init(
                        filmDisplay,
                        isLiked: isLiked,
                        isDisliked: isDisliked,
                        isLoved: isLoved
                    )
                )
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

        public func addActivity(isLiked: Bool, isLoved: Bool, isDisliked: Bool) {
            guard isLiked || isLoved || isDisliked else {
                removeFromLibrary()
                // TODO: show confirmation
                return
            }

            self.isLiked = isLiked
            self.isLoved = isLoved
            self.isDisliked = isDisliked

            let cdFilm = saveToLibraryIfNecessary()

            guard let cdFilm, let context = cdFilm.managedObjectContext else { return }

            cdFilm.isLiked = isLiked
            cdFilm.isLoved = isLoved
            cdFilm.isDisliked = isDisliked

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
            self.isLiked = false
            self.isLoved = false
            self.isDisliked = false

            try? movieProvider.deleteFilm(filmDisplay.id)
            setMenuActions()
        }

        private func markAsWatched() {
            self.isLiked = false
            self.isLoved = false
            self.isDisliked = false

            try? movieProvider.saveFilmToLibrary(
                .init(
                    filmDisplay,
                    isLiked: false,
                    isDisliked: false,
                    isLoved: false
                )
            )
            setMenuActions()
        }

        private func addToWatchList() {
            self.isLiked = false
            self.isLoved = false
            self.isDisliked = false

            try? movieProvider.saveFilmToWatchLater(self.filmDisplay)
            setMenuActions()
        }

        private func setMenuActions() {
            var destructiveAction: UIAction?
            var menu = [UIMenu]()
            var actions = [UIAction]()

            outer: if let existingFilm = movieProvider.fetchFilm(filmDisplay.id) {
                guard existingFilm.isOnWatchList else {
                    destructiveAction = UIAction(title: "Remove from Library", image: UIImage(systemName: "trash"), attributes: .destructive) { (action) in
                        self.removeFromLibrary()
                    }
                    break outer
                }

                let watchListAction = UIAction(title: "Remove from Watch List", image: UIImage(systemName: "rectangle.stack.badge.minus")) { (action) in
                    self.removeFromLibrary()
                }
                actions.append(watchListAction)

            } else {
                let watchedAction = UIAction(title: "Mark as Watched", image: UIImage(systemName: "checkmark.circle")) { (action) in
                    self.markAsWatched()
                }
                actions.append(watchedAction)

                let watchListAction = UIAction(title: "Add to Watch List", image: UIImage(systemName: "rectangle.stack.badge.plus")) { (action) in
                    self.addToWatchList()
                }
                actions.append(watchListAction)
            }

            // Share Menu
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { (action) in
                print("Users action was tapped")
            }
            let shareMenu = UIMenu(title: "", options: .displayInline, children: [shareAction])
            menu.append(shareMenu)

            // Actions Menu
            let actionMenu = UIMenu(title: "", options: .displayInline, children: actions)
            menu.append(actionMenu)

            // Destructive menu
            if let destructiveAction {
                let destructiveMenu = UIMenu(title: "", options: .displayInline, children: [destructiveAction])
                menu.append(destructiveMenu)
            }

            menuActions = menu
        }
    }
}

// MARK: - UIViewRepresentable Button

// More options: Share, Add to collection, change poster? (premium),
struct ButtonWithSourceView: UIViewRepresentable {
    @Binding var menu: [UIMenu]

    func makeUIView(context: Context) -> UIButton {
        let uiButton = UIButton()
        uiButton.translatesAutoresizingMaskIntoConstraints = false
        let uiImage = UIImage(systemName: "ellipsis")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        uiButton.setImage(uiImage, for: .normal)
        uiButton.menu = UIMenu(title: "", options: .displayInline, children: menu)
        uiButton.showsMenuAsPrimaryAction = true

        // Prevent it from expanding
        uiButton.setContentHuggingPriority(.required, for: .horizontal)
        uiButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        return uiButton
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.menu = UIMenu(title: "", options: .displayInline, children: menu)
    }
}
