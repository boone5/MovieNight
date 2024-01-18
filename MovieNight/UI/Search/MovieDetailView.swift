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

    @State private var showRatingSheet = false
    @State private var rating: Int16 = 0
    @State private var didReview: Bool = false

    var details: DetailViewRepresentable

    private var imgData: Data? {
        get {
            // If its a CD model we want to return the poster data from that model. Otherwise, return whats in the cache from Search.
            if let cdModel = details as? MovieDetails, let imgData = cdModel.posterData {
                return imgData
            } else {
                return ImageCache.shared.getObject(forKey: details.posterPath)
            }

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
                        .padding()
                        .background(Color.black.opacity(0.10))
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding([.leading, .trailing], 30)
            .padding(.bottom, 20)

            if let imgData, let uiimage = UIImage(data: imgData) {
                Image(uiImage: uiimage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .frame(width: 300)
                    .frame(height: 400)
            } else {
                Rectangle()
                    .frame(width: 250, height: 400)
                    .cornerRadius(15)
            }

            Text(details.title)
                .frame(maxWidth: 300)
                .multilineTextAlignment(.center)
                .font(.title)
                .padding(.top, 20)

            Text("Released in " + details.releaseDate)
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(Color(uiColor: UIColor.systemGray))
                .padding(.top, 10)
                .padding(.bottom, 20)

            HStack {
                ZStack {
                    Button {
                        self.showRatingSheet = true
                        self.didReview = false
                    } label: {
                        Capsule()
                            .frame(height: 50)
                            .foregroundStyle(Color.black.opacity(0.10))
                    }
                    .sheet(isPresented: $showRatingSheet, onDismiss: onSheetDismiss) {
                        RatingSheet(rating: $rating, didReview: $didReview)
                            .presentationDetents([.fraction(0.3)])
                            .presentationDragIndicator(.visible)
                    }

                    Text("Leave a rating")
                        .foregroundStyle(Color(uiColor: UIColor.systemGray))
                }
            }
            .padding([.leading, .trailing], 30)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden()
    }

    private func onSheetDismiss() {
        if didReview {
            let id = details.id

            guard let movieDetails_CD = MovieProvider.shared.exists(id: id) else {
                print("ℹ️ Movie doesn't exist in Core Data. Creating new object.")

                let movieDetails = MovieDetails.createCoreDataModel(from: details, in: MovieProvider.shared.viewContext)
                movieDetails.posterData = imgData
                movieDetails.userRating = rating

                return
            }

            MovieProvider.shared.update(entity: movieDetails_CD, userRating: rating)
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

//struct SearchResultDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatefulPreviewWrapper(NavigationPath()) { MovieDetailView(vm: <#MovieDetailViewModel#>, path: $0) }
////        RatingSheet()
//    }
//}

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
