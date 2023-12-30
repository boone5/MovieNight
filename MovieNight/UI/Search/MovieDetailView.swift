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

    let details: MovieResponseTMDB.Details

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

            #warning("TODO: Match devices corner radius?")
            if let imgData = ImageCache.shared.getObject(forKey: details.posterPath), let uiimage = UIImage(data: imgData) {
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
                    } label: {
                        Capsule()
                            .frame(height: 50)
                            .foregroundStyle(Color.black.opacity(0.10))
                    }
                    .sheet(isPresented: $showRatingSheet) {
                        RatingSheet()
                            .presentationDetents([.medium])
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
}

struct RatingSheet: View {
    @State private var rating: Int = 3
    @State private var isPressed: Bool = false

    private static let font1 = Font.system(size: 20)
    private static let font2 = Font.system(size: 45)

    @State private var color = Color.red
    @State private var currentFont = font1

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

            Text(ratingState.image)
                .font(.system(size: 80))
                .padding(.bottom, 10)

            RatingDetailsView(ratingState: ratingState)
                .padding(.bottom, 20)

            HStack(spacing: 20) {
                ForEach(1..<6) { index in
                    #warning("TODO: Add particle animation in background on select")
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 42, height: 42)
                        .foregroundColor(ratingState.foregroundColor)
                        .scaleEffect(isPressed ? 0.8 : 1.0)
                        .onTapGesture {
                            rating = (index == rating) ? index - 1 : index
                            
                            withAnimation {
                                isPressed.toggle()
                            }
                            withAnimation(.easeInOut(duration: 0.15).delay(0.1)) {
                                isPressed.toggle()
                            }
                        }
                }
            }

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
        StatefulPreviewWrapper(NavigationPath()) { MovieDetailView(path: $0, details: MovieResponseTMDB.Details.mockedData) }
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
