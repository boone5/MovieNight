//
//  MovieDetailView.swift
//  MovieNight
//
//  Created by Boone on 10/18/23.
//

import SwiftUI

// Lottie Animations: https://iconscout.com/lottie-animation-pack/emoji-282

struct MovieDetailView: View {
    @Binding var path: NavigationPath

    @StateObject var viewModel: MovieDetailViewModel

    @State private var showRatingSheet = false
    @State private var localRating: Int16 = 0
    @State private var didReview: Bool = false

    private var imgData: Data? {
        get {
            viewModel.getImageData()
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    self.path.removeLast()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(.black)
                }

                Spacer()
            }
            .padding([.bottom, .leading, .trailing], 20)

            ScrollView {
                VStack(spacing: 0) {
                    if let imgData, let uiimage = UIImage(data: imgData) {
                        Image(uiImage: uiimage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
                            .frame(width: 300, height: 400)

                    } else {
                        Rectangle()
                            .frame(width: 300, height: 400)
                            .cornerRadius(15)
                    }

                    Text(viewModel.details.title)
                        .frame(maxWidth: 300)
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.top, 20)

                    // Stars/Ratings + Optional(userRating)
                    HStack(spacing: 30) {
                        // Stars/Ratings Stack
                        VStack {
                            // Stars Stack
                            HStack(spacing: 0) {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < viewModel.voteAverage ? "star.fill" : "star")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(.black)
                                }
                            }

                            Text(String(viewModel.details.voteCount) + " ratings")
                                .font(.caption)
                                .fontWeight(.regular)
                        }

                        // User Rating
                        if viewModel.didLeaveReview {
                            ZStack {
                                Rectangle()
                                    .frame(width: 80)
                                    .frame(maxHeight: .infinity)
                                    .foregroundStyle(Color.clear)
                                    .cornerRadius(8)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.black, style: StrokeStyle(lineWidth: 2))
                                    }

                                HStack {
                                    Text(String(viewModel.details.userRating))
                                        .font(.title3)
                                        .fontWeight(.medium)

                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(alignment: .center)
                        }
                    }
                    .padding(.top, 10)

                    if !viewModel.didLeaveReview {
                        ZStack {
                            Button {
                                self.showRatingSheet = true
                                self.didReview = false
                            } label: {
                                Rectangle()
                                    .frame(height: 50)
                                    .frame(maxWidth: 300)
                                    .foregroundStyle(Color.black)
                                    .cornerRadius(8)
                            }
                            .sheet(isPresented: $showRatingSheet, onDismiss: onSheetDismiss) {
                                RatingSheet(rating: $localRating, didReview: $didReview)
                                    .presentationDetents([.fraction(0.3)])
                                    .presentationDragIndicator(.visible)
                            }

                            Text("Leave a rating")
                                .foregroundStyle(Color.white)
                        }
                        .padding(.top, 10)
                    }

                    Divider()
                        .padding([.top], 20)
                        .padding([.leading, .trailing], 30)

                    Text("Overview")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 30)
                        .padding([.top], 20)

                    Text(viewModel.details.overview)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 30)
                        .padding(.top, 10)

                    Divider()
                        .padding([.top], 20)
                        .padding([.leading, .trailing], 30)

                    HStack(alignment: .center, spacing: 0) {
                        VStack(spacing: 10) {
                            Text("Genre")
                                .frame(width: 100, alignment: .leading)
                                .font(.headline)
                                .fontWeight(.bold)

                            Text("Duration")
                                .frame(width: 100, alignment: .leading)
                                .font(.headline)
                                .fontWeight(.bold)

                            Text("Released")
                                .frame(width: 100, alignment: .leading)
                                .font(.headline)
                                .fontWeight(.bold)
                        }

                        VStack(spacing: 10) {
                            Text("Comedy, Romance")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .font(.subheadline)

                            Text("120 minutes")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .font(.subheadline)

                            Text("Jan. 24th, 2024")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .font(.subheadline)
                        }

                        Spacer()
                    }
                    .padding([.top], 20)
                    .padding([.leading, .trailing], 30)

                    Divider()
                        .padding([.top], 20)
                        .padding([.leading, .trailing], 30)

                    Text("You might also like")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 30)
                        .padding([.top], 20)

                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 10) {
                            ForEach(viewModel.recommendedMovies) { movie in
                                ThumbnailView(url: movie.posterPath, width: 175, height: 250)
                            }
                        }
                    }
                    .safeAreaInset(edge: .leading, spacing: 0) {
                        VStack(spacing: 0) { }.padding(.leading, 30)
                    }
                    .safeAreaInset(edge: .trailing, spacing: 0) {
                        VStack { }.padding(.trailing, 30)
                    }
                    .padding([.top], 20)

                    Divider()
                        .padding([.top], 20)
                        .padding([.leading, .trailing], 30)

                    Text("Cast")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 30)
                        .padding([.top], 20)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await viewModel.fetchRecommendedMovies()
        }
    }

    private func onSheetDismiss() {
        if didReview {
            let id = viewModel.details.id

            guard let existing = MovieProvider.shared.exists(id: id) else {
                print("ℹ️ Movie doesn't exist in Core Data. Creating new object.")

                let movieDetails = Details_CD.createCoreDataModel(from: viewModel.details, in: MovieProvider.shared.viewContext)
                movieDetails.posterData = imgData
                movieDetails.userRating = localRating

                MovieProvider.shared.save()

                viewModel.didLeaveReview = true
                viewModel.details.userRating = localRating

                return
            }

            MovieProvider.shared.update(entity: existing, userRating: localRating)
        } else {
            print("ℹ️ No review was submitted; no data will be saved.")
        }
    }
}

struct RatingSheet: View {
    @Binding var rating: Int16
    @Binding var didReview: Bool

    var ratingState: Rating {
        switch rating {
        case 1:
            return .horrible
        case 2:
            return .notRecommend
        case 3:
            return .neutral
        case 4:
            return .recommend
        case 5:
            return .amazing
        default:
            return .horrible
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("What did you think of the movie?")
                .frame(width: UIScreen.main.bounds.width * 0.85)
                .multilineTextAlignment(.center)
                .font(.title2).fontWeight(.medium)
                .padding(.bottom, 20)

            Spacer()

            HStack(spacing: 20) {
                ForEach(1..<6) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 42, height: 42)
                        .foregroundColor(ratingState.foregroundColor)
                        .onTapGesture {
                            let rating = (index == rating) ? index - 1 : index
                            self.rating = Int16(rating)
                            didReview = true
                        }
                }
            }

            RatingDetailsView(ratingState: ratingState)
                .padding([.top, .bottom], 20)

            Spacer()

        }
        .padding(.top, 40)
    }
}

struct RatingDetailsView: View {
    var ratingState: Rating

    var body: some View {
        VStack(spacing: 10) {
            Text(ratingState.title)
                .font(.headline)
                .fontWeight(.medium)

            Text(ratingState.description)
                .font(.subheadline)
        }

    }
}

enum Rating {
    case horrible
    case notRecommend
    case neutral
    case recommend
    case amazing

    var title: String {
        switch self {
        case .horrible:
            "Horrible"
        case .notRecommend:
            "Don't Recommend"
        case .neutral:
            "Neutral"
        case .recommend:
            "Recommend"
        case .amazing:
            "INCREDIBLE"
        }
    }

    var description: String {
        switch self {
        case .horrible:
            "Please do not watch!"
        case .notRecommend:
            "Decent, but wouldn't watch again..."
        case .neutral:
            "Meh... Need to watch again."
        case .recommend:
            "Can't go wrong with this one."
        case .amazing:
            "Would definitely watch again!"
        }
    }

    var foregroundColor: Color {
        switch self {
        case .horrible:
            .red
        case .notRecommend:
            .orange
        case .neutral:
            .gray
        case .recommend:
            .blue
        case .amazing:
            .green
        }
    }

    var image: String {
        switch self {
        case .horrible:
            "😡"
        case .notRecommend:
            "😴"
        case .neutral:
            "😳"
        case .recommend:
            "🙂"
        case .amazing:
            "😍"
        }
    }
}

struct SearchResultDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(NavigationPath()) { MovieDetailView(path: $0, viewModel: .init(details: MovieResponseTMDB.Details.mockedData)) }
//        RatingSheet()
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    var body: some View {
        content($value)
    }

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
}
