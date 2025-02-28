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

#Preview {
    @Previewable @State var isExpanded: Bool = true
    @Previewable @Namespace var namespace

    let previewCD = MovieProvider.preview.container.viewContext
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

    @State private var showCommentModal: Bool = false
    @State private var presentationDidFinish: Bool = false

    public var comment: String? = nil

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
        VStack(alignment: .center, spacing: 0) {
            TrackableScrollView(
                .vertical,
                showIndicators: true,
                contentOffset: $scrollViewContentOffset
            ) {
                VStack(alignment: .center, spacing: 0) {
                    headerView
                        .padding(.top, 80)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                        .opacity(presentationDidFinish ? 1 : 0)

                    // MARK: TODO
                    // - Add gloss finish
                    FlippablePosterView

                    Group {
                        Text(viewModel.film.title ?? "")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.top, 30)
                            .padding(.horizontal, 30)

                        Text("Thriller, Drama, Mystery")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color(uiColor: .systemGray2))
                            .padding(.top, 10)

                        ButtonsContainerView(
                            isLiked: $viewModel.isLiked,
                            isLoved: $viewModel.isLoved,
                            isDisliked: $viewModel.isDisliked,
                            didAddActivity: { isLiked, isLoved, isDisliked in
                                viewModel.addActivity(isLiked: isLiked, isLoved: isLoved, isDisliked: isDisliked)
                            }
                        )
                        .padding(.top, 30)

                        if case .tvShow = viewModel.film.mediaType {
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
                            .padding(.top, 45)
                        }

                        Text("You might like")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(uiColor: .systemGray2))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 45)

                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(1..<5) { _ in
                                    RoundedRectangle(cornerRadius: 8)
                                        .frame(width: 175, height: 250)
                                }
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 80)
                        }
                    }
                    .padding(.horizontal, 30)
                    .opacity(presentationDidFinish ? 1 : 0)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 10)
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
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .matchedGeometryEffect(id: "background" + String(viewModel.film.id), in: namespace, isSource: false)
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
        .sheet(isPresented: $showCommentModal) {
            CommentModalView(vm: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4)) {
                presentationDidFinish.toggle()
            }
        }
        .task {
            await viewModel.getAdditionalTVDetails()
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

            // More options: Share, Add to collection, change poster? (premium),
            Image(systemName: "ellipsis")
                .foregroundStyle(.white)
                .padding(12)
                .background {
                    Circle()
                        .foregroundStyle(Color(uiColor: .white).opacity(0.2))
                }
        }
    }

    @MainActor
    var FlippablePosterView: some View {
        ZStack {
            ZStack(alignment: .bottomLeading) {
                // Front face (Blue)
                PosterView(
                    width: posterWidth,
                    height: posterHeight,
                    uiImage: uiImage,
                    filmID: viewModel.film.id,
                    namespace: namespace,
                    isAnimationSource: false
                )
                .shadow(radius: 6, y: 3)

                // TODO: Add a progress wheel
            }
            .opacity(frontVisible ? 1 : 0)
            .rotation3DEffect(
                .degrees(flipDegrees),
                axis: (x: 0, y: 1, z: 0)
            )

            PosterBackView(film: viewModel.film, backgroundColor: viewModel.averageColor)
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
                .bouncy(duration: 1.2, extraBounce: 0.3)
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
}

struct FilmDetailButtonView: View {
    let imageName: String
    let width: CGFloat
    let height: CGFloat
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 0) {
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: width, height: height)
                    .foregroundStyle(.white)
            }
            .frame(width: 70)
        }
    }
}

// MARK: CommentModalView

struct CommentModalView: View {
    @ObservedObject var vm: FilmDetailView.ViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 0) {
            TextField(text: $text) {
                Text("Enter a comment...")
                    .foregroundStyle(Color(uiColor: MovieNightColors.subtitle))
            }

            Spacer()

            Button {
                // do something
                //                vm.addActivity(comment: text)
                dismiss()

            } label: {
                Text("Submit")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
            }
            .background {
                ZStack {
                    Color(uiColor: vm.averageColor)

                    if text.isEmpty == false {
                        Color(.black).opacity(0.6)
                    } else {
                        Color(.black).opacity(0.2)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.horizontal, 30)
        }
        .padding(.top, 40)
        .padding(.horizontal, 30)
        .frame(maxHeight: .infinity)
        .background {
            Color(uiColor: vm.averageColor)
                .ignoresSafeArea()
        }
    }
}

// MARK: ViewModel

// TODO: have a display model for the film
// - easier for going between response objects and core data
// - easier for using in views

extension FilmDetailView {

    /*
     - Check if current number of seasons watched and seasons released match before updating CoreData. New seasons can come out after a user has saved it.
     - Could table this for later
     - Could make notifications a premium feature when a new season is out
     */

    class ViewModel: ObservableObject {
        @Published var averageColor: UIColor
        @Published var film: DetailViewRepresentable

        @Published var isLiked: Bool = false
        @Published var isLoved: Bool = false
        @Published var isDisliked: Bool = false

        @Published var seasons: [AdditionalDetailsTVShow.Season] = []

        private let movieProvider: MovieProvider = .shared

        init(posterImage: UIImage?, film: some DetailViewRepresentable) {
            self.averageColor = posterImage?.averageColor ?? UIColor(resource: .brightRed)

            if let existingFilm = movieProvider.fetchMovieByID(film.id) {
                isLiked = existingFilm.isLiked
                isLoved = existingFilm.isLoved
                isDisliked = existingFilm.isDisliked

                self.film = existingFilm

            } else {
                self.film = film
            }
        }

        public func deleteFilm(id: Int64) {
            movieProvider.deleteMovie(by: id)
        }

        public func addActivity(comment: String? = nil, isLiked: Bool, isLoved: Bool, isDisliked: Bool) {
            let date = Date()

            if let film = film as? Film {
                guard let context = film.managedObjectContext else { return }

                let entry = Entry(context: context)
                entry.date = date
                entry.comment = comment
                film.addToEntries(entry)

                film.isLiked = isLiked
                film.isLoved = isLoved
                film.isDisliked = isDisliked

                do {
                    try context.save()
                } catch {
                    print("Failed to save: \(error)")
                }

                self.film = film
            } else {
                let entry = Entry(context: movieProvider.container.viewContext)
                entry.comment = comment
                entry.date = date

                self.isLiked = isLiked
                self.isLoved = isLoved
                self.isDisliked = isDisliked

                self.film = movieProvider.saveFilmToLibrary(film, entry: entry, isLiked: isLiked, isDisliked: isDisliked, isLoved: isLoved)
            }
        }

        public func getAdditionalTVDetails() async {
            guard film.mediaType == .tvShow else { return }

            let endpoint = DetailsEndpoint.tvShowDetails(id: film.id)

            do {
                let tvShowDetails: AdditionalDetailsTVShow = try await NetworkManager().request(endpoint)
                await MainActor.run {
                    self.seasons = tvShowDetails.seasons ?? []
                }

            } catch {
                print("⛔️ Error fetching additional details: \(error)")
            }
        }
    }
}

extension Film: DetailViewRepresentable {
    var mediaType: MediaType {
        switch mediaTypeAsString {
        case MediaType.movie.rawValue:
                .movie
        case MediaType.tvShow.rawValue:
                .tvShow
        default:
                .movie
        }
    }
}
