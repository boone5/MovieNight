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
    let film: ResponseType = ResponseType.movie(MovieResponse())

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
    @State private var isFlipped = false
    
    @State private var showCommentModal: Bool = false
    @State private var animationDidFinish: Bool = false

    public var comment: String? = nil

    var axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (0, 1, 0)

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
            headerView
                .padding(.top, 80)
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
                .opacity(animationDidFinish ? 1 : 0)

            TrackableScrollView(
                .vertical,
                showIndicators: true,
                contentOffset: $scrollViewContentOffset)
            {
                VStack(alignment: .center, spacing: 0) {
                    ZStack {
                        // MARK: TODO
                        // - Add shimmy animation
                        // - Add gloss finish
                        PosterView(
                            width: posterWidth,
                            height: posterHeight,
                            uiImage: uiImage,
                            filmID: viewModel.film.id,
                            namespace: namespace,
                            isAnimationSource: false
                        )
                            .shadow(color: .black.opacity(0.6), radius: 8, y: 4)
                            .opacity(isFlipped ? 0 : 1)
                            .overlay {
                                thumbnailBackButton
                            }
                            .rotation3DEffect(
                                .degrees(isFlipped ? -180 : 0),
                                axis: axis
                            )

                        Rectangle()
                            .foregroundStyle(.black)
                            .frame(width: posterWidth, height: posterHeight)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.6), radius: 8, y: 4)
                            .opacity(isFlipped ? 1 : 0)
                            .overlay {
                                PosterBackView(film: viewModel.film, backgroundColor: viewModel.averageColor, isFlipped: $isFlipped)
                                    .opacity(isFlipped ? 1 : 0)
                            }
                            .rotation3DEffect(
                                .degrees(isFlipped ? 0 : 180),
                                axis: axis
                            )
                    }

                    Group {
                        Text(viewModel.film.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.top, 30)
                            .padding(.horizontal, 30)

                        Text("Thriller, Drama, Mystery")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color(uiColor: .systemGray2))
                            .padding(.top, 10)

                        ActionView3(
                            isLiked: $viewModel.isLiked,
                            isLoved: $viewModel.isLoved,
                            isDisliked: $viewModel.isDisliked,
                            didAddActivity: { isLiked, isLoved, isDisliked in
                                viewModel.addActivity(isLiked: isLiked, isLoved: isLoved, isDisliked: isDisliked)
                            }
                        )
                            .padding(.top, 30)

                        Text("Activity")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(uiColor: .systemGray2))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 30)

                        ActionView(backgroundColor: viewModel.averageColor, actionType: .dateWatched(date: .now))
                            .padding(.top, 15)

                        Text("You might like")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(uiColor: .systemGray2))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 45)

                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(1..<5) { _ in
                                    RoundedRectangle(cornerRadius: 25)
                                        .frame(width: 175, height: 250)
                                }
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 80)
                        }
                    }
                    .padding(.horizontal, 30)
                    .opacity(animationDidFinish ? 1 : 0)
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
                animationDidFinish.toggle()
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
    var thumbnailBackButton: some View {
        VStack {
            Spacer()

            Text("Back")
                .font(.system(size: 12))
                .foregroundStyle(.white)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color(uiColor: viewModel.averageColor).opacity(0.2))
                        .shadow(radius: 3, y: 4)
                }
                .matchedGeometryEffect(id: "info" + String(viewModel.film.id), in: namespace, isSource: false)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        isFlipped.toggle()
                    }
                }
                .padding([.bottom, .trailing], 15)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .opacity(isFlipped ? 0 : 1)
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

extension FilmDetailView {
    class ViewModel: ObservableObject {
        enum ViewState {
            case watched
            case notWatched
        }

        @Published var viewState: ViewState = .notWatched
        @Published var averageColor: UIColor
        @Published var film: DetailViewRepresentable

        @Published var isLiked: Bool = false
        @Published var isLoved: Bool = false
        @Published var isDisliked: Bool = false

        private let movieProvider: MovieProvider = .shared

        init(posterImage: UIImage?, film: some DetailViewRepresentable) {
            self.averageColor = posterImage?.averageColor ?? UIColor(resource: .brightRed)
            self.film = film

            if let movie = movieProvider.fetchMovieByID(film.id) {
                self.viewState = .watched
                self.film = movie

                print("Film (init) context: \(movie.managedObjectContext?.description ?? "nil")")

                if let activity = movie.activity {
                    isLiked = activity.isLiked
                    isLoved = activity.isLoved
                    isDisliked = activity.isDisliked
                }

            } else {
                self.viewState = .notWatched
            }
        }

        private func addToWatched(_ film: some DetailViewRepresentable, feedback: Activity? = nil) {
            viewState = .watched
            self.film = movieProvider.saveFilm(film, feedback: feedback)
        }

        public func deleteFilm(id: Int64) {
            viewState = .notWatched
            movieProvider.deleteMovie(by: id)
        }

        public func addActivity(comment: String? = nil, isLiked: Bool, isLoved: Bool, isDisliked: Bool) {
            let filmID = film.id
            let date = Date()

            if let film = movieProvider.fetchMovieByID(film.id) {
                guard let context = film.managedObjectContext else { return }

                print("Film (addActivity) context: \(context.description)")

                var activity: Activity?

                if let activityCD = film.activity {
                    activity = activityCD
                } else {
                    activity = Activity(context: context)
                    activity?.filmID = filmID
                    activity?.date = date
                }

                activity?.isLiked = isLiked
                activity?.isLoved = isLoved
                activity?.isDisliked = isDisliked
                activity?.comment = comment

                do {
                    try context.save()
                } catch {
                    print("Failed to save: \(error)")
                }

                self.film = film
            } else {
                let activity = Activity(context: movieProvider.container.viewContext)
                activity.comment = comment
                activity.filmID = filmID
                activity.date = date
                activity.isLiked = isLiked
                activity.isLoved = isLoved
                activity.isDisliked = isDisliked

                addToWatched(film, feedback: activity)
            }
        }
    }
}
