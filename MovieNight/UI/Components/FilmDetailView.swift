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
//    let film: ResponseType = ResponseType.movie(MovieResponse())
    let film: ResponseType = ResponseType.tvShow(TVShowResponse())

    FilmDetailView(film: film, namespace: namespace, isExpanded: $isExpanded, uiImage: nil)
}

// MARK: FilmDetailView

struct FilmDetailView: View {
    @StateObject var viewModel: FilmDetailView.ViewModel

    private let posterWidth: CGFloat
    private let posterHeight: CGFloat

    let uiImage: UIImage?
    let namespace: Namespace.ID

    @Binding var isExpanded: Bool

    @State private var scrollViewContentOffset = CGFloat(0)
    @State private var presentationDidFinish: Bool = false

    // This state tracks the cumulative rotation of the card.
    @State private var flipDegrees: Double = 0
    @State private var shimmyRotation: Double = 0

    // Normalize the degrees into [0, 360) for determining which side is visible.
    var normalizedDegrees: Double {
        abs(flipDegrees.truncatingRemainder(dividingBy: 360))
    }

    var frontVisible: Bool {
        normalizedDegrees < 90 || normalizedDegrees > 270
    }

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

        let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.size ?? .zero

        self.posterWidth = size.width / 1.5
        self.posterHeight = size.height / 2.4
    }

    var body: some View {
        TrackableScrollView(
            .vertical,
            showIndicators: true,
            contentOffset: $scrollViewContentOffset
        ) {
            VStack(alignment: .center, spacing: 0) {
                headerView
                    .padding(.bottom, 30)
                    .opacity(presentationDidFinish ? 1 : 0)

                // MARK: TODO
                // - Add gloss finish
                FlippablePosterView

                Group {
                    Text(viewModel.filmDisplay.title ?? "")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.top, 30)

                    Text(viewModel.genres ?? "-")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                        .padding(.top, 10)

                    FeedbackButtons(
                        isLiked: $viewModel.isLiked,
                        isLoved: $viewModel.isLoved,
                        isDisliked: $viewModel.isDisliked,
                        averageColor: viewModel.averageColor,
                        didAddActivity: { isLiked, isLoved, isDisliked in
                            viewModel.addActivity(isLiked: isLiked, isLoved: isLoved, isDisliked: isDisliked)
                        }
                    )
                    .padding(.top, 30)

                    CommentPromptView(
                        averageColor: viewModel.averageColor,
                        comments: viewModel.filmDisplay.comments,
                        didTapSave: { comment in
                            viewModel.addComment(text: comment)
                        }
                    )
                    .padding(.top, 30)

                    ParticipantsView(averageColor: viewModel.averageColor)
                        .padding(.top, 30)

                    if case .tvShow = viewModel.filmDisplay.mediaType {
                        SeasonsScrollView(viewModel: viewModel)
                            .padding(.top, 30)
                    }

                    CastScrollView(averageColor: viewModel.averageColor, cast: viewModel.cast)
                        .padding(.top, 30)
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
                            colors: [Color(uiColor: viewModel.averageColor), .black],
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

    @MainActor
    var FlippablePosterView: some View {
        ZStack {
            // Front
            PosterView(
                width: posterWidth,
                height: posterHeight,
                uiImage: uiImage,
                filmID: viewModel.filmDisplay.id,
                namespace: namespace,
                isAnimationSource: false
            )
            .shadow(radius: 6, y: 3)
            .overlay(alignment: .bottomTrailing) {
                Text("Info")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .foregroundStyle(.white)
                    .background {
                        Color(uiColor: viewModel.averageColor).opacity(0.5)
                            .clipShape(Capsule())
                    }
                    .padding([.bottom, .trailing], 15)
                    .onTapGesture {
                        withAnimation(.bouncy(duration: 1.2)) {
                            flipDegrees -= 180
                        }
                    }
            }
            .opacity(frontVisible ? 1 : 0)
            .rotation3DEffect(
                .degrees(flipDegrees),
                axis: (x: 0, y: 1, z: 0)
            )

            PosterBackView(
                film: viewModel.filmDisplay,
                backgroundColor: viewModel.averageColor,
                trailer: $viewModel.trailer
            )
                .shadow(radius: 6, y: 3)
                .frame(width: posterWidth, height: posterHeight)
                .cornerRadius(8)
                .opacity(frontVisible ? 0 : 1)
                // Add 180° so that when the card flips, the back isn’t upside down.
                .rotation3DEffect(
                    .degrees(flipDegrees + 180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        // Apply the shimmy rotation effect.
        .rotation3DEffect(.degrees(shimmyRotation), axis: (x: 0, y: 1, z: 0))
        .onAppear {
            let shimmyAnimation = Animation
                .bouncy(duration: 1.2, extraBounce: 0.4)
                .repeatCount(2)

            withAnimation(shimmyAnimation) {
                shimmyRotation = 7

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(shimmyAnimation) {
                        shimmyRotation = 0
                    }
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    withAnimation(.bouncy(duration: 1.2)) {
                        // For a left-to-right swipe, add 180°.
                        if value.translation.width > 0 {
                            flipDegrees += 180
                        } else if value.translation.width < 0 {
                            // For a right-to-left swipe, subtract 180°.
                            flipDegrees -= 180
                        }
                    }
                }
        )
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
                            SeasonPosterView(posterPath: season.posterPath, seasonNum: season.seasonNumber)
                        }
                    }
                    .padding([.horizontal], 30)
                }
                .scrollIndicators(.hidden)
                .padding([.horizontal], -30)
            }
            .padding(20)
            .background(Color(uiColor: viewModel.averageColor).opacity(0.4))
            .cornerRadius(12)
        }
    }
}

// MARK: ViewModel

extension FilmDetailView {

    /*
     - Check if current number of seasons watched and seasons released match before updating CoreData. New seasons can come out after a user has saved it.
     - Could table this for later
     - Could make notifications a premium feature when a new season is out
     */

    class ViewModel: ObservableObject {
        @Published var averageColor: UIColor
        @Published var filmDisplay: FilmDisplay

        @Published var isLiked: Bool = false
        @Published var isLoved: Bool = false
        @Published var isDisliked: Bool = false

        @Published var menuActions: [UIMenu] = []
        @Published var cast: [ActorResponse.Actor] = []
        @Published var seasons: [AdditionalDetailsTVShow.Season] = []
        @Published var trailer: AdditionalDetailsMovie.VideoResponse.Video?
        @Published var genres: String?

        private let movieProvider: MovieProvider = .shared

        init(posterImage: UIImage?, film: some DetailViewRepresentable) {
            self.averageColor = posterImage?.averageColor ?? UIColor(resource: .brightRed)

            if let existingFilm = movieProvider.fetchFilmByID(film.id) {
                isLiked = existingFilm.isLiked
                isLoved = existingFilm.isLoved
                isDisliked = existingFilm.isDisliked

                self.filmDisplay = FilmDisplay(from: existingFilm)

            } else {
                self.filmDisplay = FilmDisplay(from: film)
            }

            setMenuActions()
        }

        public func addComment(text: String) {
            let date = Date()

            if let existingFilm = MovieProvider.shared.fetchFilmByID(filmDisplay.id) {
                guard let context = existingFilm.managedObjectContext else { return }

                let comment = Comment(context: context)
                comment.date = date
                comment.text = text
                existingFilm.addToComments(comment)

                do {
                    try context.save()
                } catch {
                    print("Failed to save: \(error)")
                }

                self.filmDisplay = FilmDisplay(from: existingFilm)

            } else {
                let comment = Comment(context: movieProvider.container.viewContext)
                comment.text = text
                comment.date = date

                let coreDataFilm = movieProvider.saveFilmToLibrary(
                    filmDisplay,
                    comment: comment,
                    isLiked: isLiked,
                    isDisliked: isDisliked,
                    isLoved: isLoved
                )

                self.filmDisplay = FilmDisplay(from: coreDataFilm)
            }
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

            if let existingFilm = MovieProvider.shared.fetchFilmByID(filmDisplay.id) {
                guard let context = existingFilm.managedObjectContext else { return }

                existingFilm.isLiked = isLiked
                existingFilm.isLoved = isLoved
                existingFilm.isDisliked = isDisliked

                do {
                    try context.save()
                } catch {
                    print("Failed to save: \(error)")
                }

                self.filmDisplay = FilmDisplay(from: existingFilm)
            } else {
                let coreDataFilm = movieProvider.saveFilmToLibrary(
                    filmDisplay,
                    isLiked: isLiked,
                    isDisliked: isDisliked,
                    isLoved: isLoved
                )
                self.filmDisplay = FilmDisplay(from: coreDataFilm)
            }

            setMenuActions()
        }

        public func getAdditionalDetailsTVShow() async {
            do {
                let endpoint = TMDBEndpoint.tvShowDetails(id: filmDisplay.id)
                let tvShowDetails: AdditionalDetailsTVShow = try await NetworkManager().request(endpoint)
                let genres = tvShowDetails.genres.map { $0.name }.joined(separator: ", ")

                let releasedSeasons = tvShowDetails.seasons?.compactMap { season in
                    if season.episodeCount > 1 && season.seasonNumber != 0 {
                        return season
                    } else {
                        return nil
                    }
                }

                await MainActor.run {
                    self.seasons = releasedSeasons ?? []
                    self.genres = genres
                }

            } catch {
                print("⛔️ Error fetching additional details: \(error)")
            }
        }
        
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
