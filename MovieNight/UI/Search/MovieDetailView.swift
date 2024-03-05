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

    @StateObject var viewModel: MovieDetailViewModel = MovieDetailViewModel()

    @State private var showRatingSheet = false
    @State private var localRating: Int16 = 0
    @State private var didReview: Bool = false

    var imgData: Data?
    var movieID: Int64

    var body: some View {
        ZStack {
            Color.clear
                .background {
                    LinearGradient(colors: [Color("BackgroundColor1"), Color("BackgroundColor2")], startPoint: .top, endPoint: .bottom)
                }
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        self.path.removeLast()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }

                    Spacer()
                }
                .padding([.bottom, .leading, .trailing], 20)

                ScrollView {
                    VStack(spacing: 0) {
                        if let imgData, let uiimage = UIImage(data: imgData) {
                            Image(uiImage: uiimage)
                                .resizable()
                                .frame(width: 175, height: 240)
                                .scaledToFit()
                                .cornerRadius(15)
                                .overlay {
                                    MarqueeLightFrameView()
                                }
                                .padding(50)

                        } else {
                            Rectangle()
                                .frame(width: 175, height: 240)
                                .foregroundColor(.blue)
                                .cornerRadius(15)
                                .overlay {
                                    MarqueeLightFrameView()
                                }
                                .padding(50)
                        }

                        Text(viewModel.details?.title ?? "Debug Title")
                            .frame(maxWidth: 300)
                            .multilineTextAlignment(.center)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.top, 15)

                        Group {
                            if !viewModel.didLeaveReview {
                                ZStack {
                                    Button {
                                        self.showRatingSheet = true
                                        self.didReview = false
                                    } label: {
                                        Rectangle()
                                            .frame(height: 35)
                                            .frame(maxWidth: 150)
                                            .foregroundStyle(Color("BrightRed"))
                                            .cornerRadius(8)
                                            .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 4)
                                    }
                                    .sheet(isPresented: $showRatingSheet, onDismiss: onSheetDismiss) {
                                        RatingSheet(rating: $localRating, didReview: $didReview)
                                            .presentationDetents([.fraction(0.3)])
                                            .presentationDragIndicator(.visible)
                                    }

                                    Text("Leave a rating")
                                        .foregroundStyle(Color.white)
                                        .font(.subheadline)
                                        .fontWeight(.regular)
                                }
                            } else {
                                ZStack {
                                    Rectangle()
                                        .frame(width: 100, height: 35)
                                        .frame(maxHeight: .infinity)
                                        .foregroundStyle(Color("BrightRed"))
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)

                                    HStack {
                                        Text(String(viewModel.userRating))
                                            .foregroundStyle(Color.white)
                                            .font(.title2)
                                            .fontWeight(.bold)

                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color("Gold"))
                                    }
                                }
                                .frame(alignment: .center)
                            }
                        }
                        .padding(.top, 15)

                        Divider()
                            .overlay(.white.opacity(0.3))
                            .padding([.top], 20)
                            .padding([.leading, .trailing], 30)

                        Text("Overview")
                            .foregroundStyle(.white)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .trailing], 30)
                            .padding([.top], 20)

                        Text(viewModel.details?.overview ?? "N/A")
                            .foregroundStyle(.white)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .trailing], 30)
                            .padding(.top, 10)

                        Divider()
                            .overlay(.white.opacity(0.3))
                            .padding([.top], 20)
                            .padding([.leading, .trailing], 30)

                        HStack(alignment: .center, spacing: 0) {
                            VStack(spacing: 10) {
                                Text("Genre")
                                    .foregroundStyle(.white)
                                    .frame(width: 100, alignment: .leading)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text("Duration")
                                    .foregroundStyle(.white)
                                    .frame(width: 100, alignment: .leading)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text("Released")
                                    .foregroundStyle(.white)
                                    .frame(width: 100, alignment: .leading)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text("Ratings")
                                    .foregroundStyle(.white)
                                    .frame(width: 100, alignment: .leading)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Comedy, Romance")
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .font(.subheadline)

                                Text("120 minutes")
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .font(.subheadline)

                                Text("Jan. 24th, 2024")
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .font(.subheadline)

                                // Stars Stack
                                HStack(spacing: 5) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: index < viewModel.voteAverage ? "star.fill" : "star")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                            .foregroundStyle(Color("Gold"))
                                    }
                                }
                            }

                            Spacer()
                        }
                        .padding([.top], 20)
                        .padding([.leading, .trailing], 30)

                        Divider()
                            .overlay(.white.opacity(0.3))
                            .padding([.top], 20)
                            .padding([.leading, .trailing], 30)

                        Text("You might also like")
                            .foregroundStyle(.white)
                            .font(.headline)
                            .fontWeight(.semibold)
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
                            .overlay(.white.opacity(0.3))
                            .padding([.top], 20)
                            .padding([.leading, .trailing], 30)

                        Text("Cast")
                            .foregroundStyle(.white)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .trailing], 30)
                            .padding([.top], 20)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await viewModel.fetchAdditionalDetails(movieID)
        }
    }

    private func onSheetDismiss() {
        if didReview {
            let id = movieID

            guard let existing = MovieProvider.shared.exists(id: id) else {
                print("ℹ️ Movie doesn't exist in Core Data. Creating new object.")

                let movieDetails = Movie_CD(context: MovieProvider.shared.viewContext)
                movieDetails.posterData = imgData
                movieDetails.userRating = localRating
                movieDetails.id = movieID

                MovieProvider.shared.save()

                viewModel.didLeaveReview = true
                viewModel.userRating = localRating

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
        StatefulPreviewWrapper(NavigationPath()) { MovieDetailView(path: $0, movieID: Int64(123456)) }
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
