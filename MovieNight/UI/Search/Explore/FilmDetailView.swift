//
//  FilmDetailView.swift
//  MovieNight
//
//  Created by Boone on 10/1/24.
//

import CoreData
import SwiftUI
import SwiftUITrackableScrollView

//#Preview {
//    @State var isExpanded: Bool = true
//    @State var showDetailView: Bool = true
//    @Namespace var namespace
//
//    var film: FilmWithImage = FilmWithImage(
//        result: ResponseType.movie(MovieResponse(id: 0, adult: nil, backdropPath: nil, genreIDs: [], originalLanguage: "", originalTitle: "", overview: "Lorem ipsum dolor sit amet, consect adipisc elit, sed do eiusmod tempor incidid ut labore et dolore magna. Ut enim ad minim veniam, quis", popularity: 5.0, posterPath: nil, releaseDate: "July 27th, 2020", title: "Preview Movie Title", video: false, voteAverage: 5.4, voteCount: 200, mediaType: "Movie")),
//        image: nil,
//        averageColor: UIColor(resource: .brightRed)
//    )
//
////    ReviewModalView(backgroundColor: UIColor(resource: .backgroundColor2))
//    FilmDetailView(film: film, namespace: namespace, isExpanded: $isExpanded)
//}

// MARK: FilmDetailView

struct FilmDetailView: View {
    @StateObject var viewModel: FilmDetailView.ViewModel

    var film: ResponseType
    var namespace: Namespace.ID

    @Binding var isExpanded: Bool

    @State private var scrollViewContentOffset = CGFloat(0)
    @State private var isFlipped = false
    @State var date: Date = .now

    @State private var showAddReviewModal: Bool = false

    var axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (0, 1, 0)

    init(movieDataStore: MovieDataStore, film: ResponseType, namespace: Namespace.ID, isExpanded: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: FilmDetailView.ViewModel(movieDataStore: movieDataStore))
        _isExpanded = isExpanded

        self.film = film
        self.namespace = namespace

    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            headerView
                .padding(.top, 80)
                .padding(.horizontal, 30)
                .padding(.bottom, 10)

            // Taken from https://stackoverflow.com/questions/72941738/closing-a-view-when-it-reaches-the-top-that-has-a-scrollview-in-swiftui
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
                        ThumbnailView(
                            url: film.posterPath,
                            id: film.id,
                            width: self.screenSize.width / 1.5,
                            height: self.screenSize.height / 2.4,
                            namespace: namespace
                        )
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
                            .frame(width: self.screenSize.width / 1.5, height: self.screenSize.height / 2.4)
                            .cornerRadius(15)
                            .opacity(isFlipped ? 1 : 0)
                            .overlay {
                                FilmBottomSheetView(film: film, isFlipped: $isFlipped)
                                    .opacity(isFlipped ? 1 : 0)
                            }
                            .rotation3DEffect(
                                .degrees(isFlipped ? 0 : 180),
                                axis: axis
                            )
                    }

                    Text(film.title ?? "N/A")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.top, 30)
                        .padding(.horizontal, 30)

                    Text("Thriller, Drama, Mystery")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                        .padding(.top, 10)

                    HStack(spacing: 10) {

                        switch viewModel.viewState {
                        case .watched:
                            Button {
                                print("remove from watched")
                            } label: {
                                Text("Watched")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color(uiColor: film.averageColor ?? UIColor(resource: .backgroundColor1)))
                                    }
                            }

                            Button {
                                print("share action")
                            } label: {
                                Text("Share")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color(uiColor: film.averageColor ?? UIColor(resource: .backgroundColor1)))
                                    }
                            }

                        case .notWatched:
                            Button {
                                viewModel.saveFilm(film)

                            } label: {
                                Text("Add to watched")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color(uiColor: film.averageColor ?? UIColor(resource: .backgroundColor1)))
                                    }
                            }

                            Button {
                                print("Add to watch later action")
                            } label: {
                                Text("Add to watch later")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(uiColor: film.averageColor ?? UIColor(resource: .backgroundColor1)), lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 15)

                    watchedFormView
                        .padding(.horizontal, 30)
                        .padding(.top, 15)

                    Text("You might like")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(uiColor: MovieNightColors.title))
                        .padding(.top, 45)
                        .padding(.horizontal, 30)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(1..<5) { _ in
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: 175, height: 250)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        .padding(.bottom, 80)
                    }
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
                .matchedGeometryEffect(id: "background" + String(film.id), in: namespace)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(uiColor: film.averageColor ?? UIColor(resource: .backgroundColor1)), .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showAddReviewModal) {
            ReviewModalView(backgroundColor: film.averageColor ?? UIColor(resource: .backgroundColor1))
                .presentationDetents([.fraction(0.3), .large])
                .presentationDragIndicator(.hidden)
        }
        .onAppear {
            viewModel.setViewState(film)
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
                        .foregroundStyle(Color(uiColor: film.averageColor ?? UIColor(resource: .backgroundColor1)).opacity(0.2))
                        .shadow(radius: 3, y: 4)
                }
                .matchedGeometryEffect(id: "info" + String(film.id), in: namespace)
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

    @MainActor
    var watchedFormView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Rating")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(uiColor: MovieNightColors.subtitle))

                Spacer()

                Button {
                    print("showModal")
                    showAddReviewModal = true
                } label: {
                    Label(title: {
                        Text("Add rating")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.white)
                    }, icon: {
                        Image(systemName: "star")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(Color(uiColor: UIColor(resource: .gold)))
                    })
                }
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.gray.opacity(0.2))
                }
            }

            CustomDivider()

            HStack {
                Text("Thoughts")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(uiColor: MovieNightColors.subtitle))

                Spacer()

                Button {
                    print("showModal")
                    showAddReviewModal = true
                } label: {
                    Label(title: {
                        Text("Add comment")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.white)
                    }, icon: {
                        Image(systemName: "bubble")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(uiColor: UIColor(resource: .gold)))
                    })
                }
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.gray.opacity(0.2))
                }
            }

            CustomDivider()

            HStack {
                Text("Date Watched")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(uiColor: MovieNightColors.subtitle))

                Spacer()

                Button {
                    print("showModal")
                    showAddReviewModal = true
                } label: {
                    Label(title: {
                        Text("Add date")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.white)
                    }, icon: {
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 14, height: 13)
                            .foregroundStyle(Color(uiColor: UIColor(resource: .gold)))
                    })
                }
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.gray.opacity(0.2))
                }
            }
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color(uiColor: film.averageColor ?? UIColor(resource: .backgroundColor1)).opacity(0.4))
        }
    }
}

// MARK: CustomDividerView

struct CustomDivider: View {
    var body: some View {
        Rectangle()
            .frame(maxWidth: .infinity)
            .frame(height: 0.5)
            .foregroundStyle(.white).opacity(0.3)
    }
}

enum Star: CaseIterable {
    case horrible
    case alright
    case notSure
    case good
    case amazing

    var color: UIColor {
        switch self {
        case .horrible:
                .red
        case .alright:
                .orange
        case .notSure:
                .gray
        case .good:
                .green
        case .amazing:
            UIColor(resource: .gold)
        }
    }
}

// MARK: ReviewModalView

private struct ReviewModalView: View {
    var backgroundColor: UIColor
    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                Text("Cancel")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(uiColor: MovieNightColors.subtitle))

                Spacer()

                Text("Leave your thoughts")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color(uiColor: MovieNightColors.title))

                Spacer()

                Text("Submit")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(uiColor: UIColor(resource: .gold)))
            }
            .padding(.horizontal, 18)
            .padding(.top, 15)

            // Stars Stack
            HStack {
                ForEach(Star.allCases, id: \.self) { star in
                    Spacer()
//                    Image(systemName: index < viewModel.voteAverage ? "star.fill" : "star")
                    VStack(spacing: 0) {
                        Image(systemName: "star")
                            .resizable()
                            .frame(width: 45, height: 45)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 5)
                }
                Spacer()
            }
            .padding(.top, 45)
            .padding(.horizontal, 30)

            TextField(text: $text) {
                Text("Enter a comment...")
                    .foregroundStyle(Color(uiColor: MovieNightColors.subtitle))
            }
            .padding(.top, 45)
            .padding(.horizontal, 30)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color(uiColor: backgroundColor)
                .ignoresSafeArea()
        }
    }
}

// MARK: ViewModel

extension FilmDetailView {
    class ViewModel: ObservableObject {
        @Published var viewState: ViewState = .notWatched

        enum ViewState {
            case watched
            case notWatched
        }

        private let movieDataStore: MovieDataStore

        init(movieDataStore: MovieDataStore) {
            self.movieDataStore = movieDataStore
        }

        public func saveFilm(_ film: ResponseType) {
            viewState = .watched
            movieDataStore.saveFilm(film)
        }

        public func setViewState(_ film: ResponseType) {
            if movieDataStore.filmExists(film.id) {
                viewState = .watched
            } else {
                viewState = .notWatched
            }
        }
    }
}
