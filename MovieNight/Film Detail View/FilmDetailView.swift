//
//  FilmDetailView.swift
//  MovieNight
//
//  Created by Boone on 10/1/24.
//

import CoreData
import SwiftUI
// Taken from https://stackoverflow.com/questions/72941738/closing-a-view-when-it-reaches-the-top-that-has-a-scrollview-in-swiftui
import SwiftUITrackableScrollView
import YouTubePlayerKit

// MARK: Preview

#Preview {
    @Previewable @State var isExpanded: Bool = true
    @Previewable @Namespace var namespace

    let previewCD = MovieProvider.preview.container.viewContext
    let film: ResponseType = ResponseType.movie(MovieResponse())
//    let film: ResponseType = ResponseType.tvShow(TVShowResponse())

    FilmDetailView(film: film, namespace: namespace, isExpanded: $isExpanded, uiImage: nil)
}

// MARK: FilmDetailView

struct FilmDetailView: View {
    @StateObject var viewModel: FilmDetailView.ViewModel

    let uiImage: UIImage?
    let namespace: Namespace.ID
    @Binding var isExpanded: Bool

    @State private var scrollViewContentOffset = CGFloat(0)
    @State private var presentationDidFinish: Bool = false
    @State private var actionTapped: QuickAction?
    @State private var watchCount = 0

    init(
        film: some DetailViewRepresentable,
        namespace: Namespace.ID,
        isExpanded: Binding<Bool>,
        uiImage: UIImage?
    ) {
        _viewModel = StateObject(wrappedValue: FilmDetailView.ViewModel(posterImage: uiImage, film: film))
        _isExpanded = isExpanded

        self.namespace = namespace
        self.uiImage = uiImage
    }

    var averageColor: Color {
        viewModel.averageColor
    }

    var body: some View {
        TrackableScrollView(
            .vertical,
            showIndicators: true,
            contentOffset: $scrollViewContentOffset
        ) {
            VStack(alignment: .center, spacing: 30) {
                headerView
                    .opacity(presentationDidFinish ? 1 : 0)

                // MARK: TODO
                // - Add gloss finish
                FlippablePosterView(
                    film: viewModel.filmDisplay,
                    averageColor: viewModel.averageColor,
                    namespace: namespace,
                    uiImage: uiImage,
                    trailer: $viewModel.trailer
                )

                Group {
                    Text(viewModel.filmDisplay.title ?? "")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    Text(viewModel.genres ?? "-")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                        .padding(.top, -20)

                    FeedbackButtons(
                        isLiked: $viewModel.isLiked,
                        isLoved: $viewModel.isLoved,
                        isDisliked: $viewModel.isDisliked,
                        averageColor: viewModel.averageColor,
                        didAddActivity: { isLiked, isLoved, isDisliked in
                            viewModel.addActivity(isLiked: isLiked, isLoved: isLoved, isDisliked: isDisliked)
                        }
                    )

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
                }
                .opacity(presentationDidFinish ? 1 : 0)

                Spacer()
            }
            .padding(.vertical, 80)
            .padding(.horizontal, 20)
            .background {
                Rectangle()
                    .matchedGeometryEffect(id: "background" + String(viewModel.filmDisplay.id), in: namespace, isSource: false)
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
        }
        .onChange(of: scrollViewContentOffset) { _ in
            //TO KNOW THE VALUE OF OFFSET THAT YOU NEED TO DISMISS YOUR VIEW
            //                    print(scrollViewContentOffset)

            //THIS IS WHERE THE DISMISS HAPPENS
            if scrollViewContentOffset < -80 {
                withAnimation(.interpolatingSpring(duration: 0.4, bounce: 0.2)) {
                    isExpanded = false
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4)) {
                presentationDidFinish.toggle()
            }
        }
        .task {
            await viewModel.loadInitialData()
            if viewModel.filmDisplay.mediaType == .movie {
                await viewModel.getAdditionalDetailsMovie()
            } else {
                await viewModel.getAdditionalDetailsTVShow()
            }
        }
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
                .onTapGesture {
                    withAnimation(.interpolatingSpring(duration: 0.4, bounce: 0.2)) {
                        isExpanded = false
                    }
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

        private let movieProvider: MovieProvider = .shared
        private let posterImage: UIImage?

        init(posterImage: UIImage?, film: some DetailViewRepresentable) {
            self.posterImage = posterImage
            self.averageColor = Color(uiColor: UIColor(resource: .brightRed))
            self.filmDisplay = FilmDisplay(from: film)
        }

        @MainActor
        func loadInitialData() async {
            if let image = posterImage {
                let color = await Task.detached(priority: .userInitiated) {
                    image.averageColor
                }.value

                self.averageColor = Color(uiColor: color)
            }

            if let existingFilm = movieProvider.fetchFilmByID(filmDisplay.id) {
                isLiked = existingFilm.isLiked
                isLoved = existingFilm.isLoved
                isDisliked = existingFilm.isDisliked
                self.filmDisplay = FilmDisplay(from: existingFilm)
            }

            setMenuActions()
        }

        public func saveToLibraryIfNecessary() -> Film {
            if let existingFilm = MovieProvider.shared.fetchFilmByID(filmDisplay.id) {
                existingFilm
            } else {
                movieProvider.saveFilmToLibrary(
                    filmDisplay,
                    isLiked: isLiked,
                    isDisliked: isDisliked,
                    isLoved: isLoved
                )
            }
        }

        public func markSeasonAsWatched(_ season: AdditionalDetailsTVShow.SeasonResponse) {
            let cdFilm = saveToLibraryIfNecessary()

            guard let context = cdFilm.managedObjectContext else { return }

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
            let date = Date()
            let cdFilm = saveToLibraryIfNecessary()

            guard let context = cdFilm.managedObjectContext else { return }

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

            guard let context = cdFilm.managedObjectContext else { return }

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
                let tvShowDetails: AdditionalDetailsTVShow = try await NetworkManager().request(endpoint)
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
                let movieDetails: AdditionalDetailsMovie = try await NetworkManager().request(endpoint)
                let genres = movieDetails.genres.map { $0.name }.joined(separator: ", ")

                do {
                    try await MainActor.run {
                        self.trailer = try movieDetails.videos.trailer()
                        self.genres = genres
                        self.cast = Array(movieDetails.actorsOrderedByPopularity().prefix(10))
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

            MovieProvider.shared.deleteMovie(by: filmDisplay.id)
            setMenuActions()
        }

        private func markAsWatched() {
            self.isLiked = false
            self.isLoved = false
            self.isDisliked = false

            MovieProvider.shared.saveFilmToLibrary(
                filmDisplay,
                isLiked: false,
                isDisliked: false,
                isLoved: false
            )
            setMenuActions()
        }

        private func addToWatchList() {
            self.isLiked = false
            self.isLoved = false
            self.isDisliked = false

            MovieProvider.shared.saveFilmToWatchLater(self.filmDisplay)
            setMenuActions()
        }

        private func setMenuActions() {
            var destructiveAction: UIAction?
            var menu = [UIMenu]()
            var actions = [UIAction]()

            outer: if let existingFilm = MovieProvider.shared.fetchFilmByID(filmDisplay.id) {
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
