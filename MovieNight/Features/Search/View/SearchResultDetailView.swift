//
//  SearchResultDetailView.swift
//  MovieNight
//
//  Created by Boone on 10/18/23.
//

import SwiftUI

// Lottie Animations: https://iconscout.com/lottie-animation-pack/emoji-282

struct SearchResultDetailView: View {
    let movie: MovieResult
    @Binding var path: NavigationPath

    @State private var showRatingSheet = false

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

#warning("TODO: Match devices corner radius")
            Rectangle()
                .frame(maxWidth: 300)
                .frame(height: 400)
                .cornerRadius(50)

            Text(movie.titleText?.text ?? "")
                .frame(maxWidth: 300)
                .multilineTextAlignment(.center)
                .font(.title)
                .padding(.top, 15)

            Text("Released in " + String(movie.releaseYear?.year ?? -1))
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
    @State var offset = CGFloat.zero - 5
    @State var ratingState: Rating = .horrible

    private let width = UIScreen.main.bounds.width * 0.85
    private var segments: [CGFloat] {
        calculateSegments()
    }

    var body: some View {
        VStack {
            switch ratingState {
            case .horrible:
                Text("Horrible")
            case .notRecommend:
                Text("Don't Recommend")
            case .neutral:
                Text("Neutral")
            case .recommend:
                Text("Recommend")
            case .amazing:
                Text("Incredible")
            }

            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                Capsule()
                    .frame(width: width, height: 30)
                    .foregroundStyle(Color.black.opacity(0.10))

                HStack(spacing: 0) {
                    ForEach(1..<6) { num in
                        Rectangle()
                            .frame(width: width/5, height: 10)
                            .foregroundStyle(Color.black.opacity(0.15))
                            .border(Color.black)
                    }
                }

                #warning("TODO: match the Circle()'s color to the currently selected rating")
                Circle()
                    .frame(width: 45, height: 45)
                    .foregroundStyle(Color.yellow)
                    .offset(x: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.location.x > 15 && value.location.x < width - 20 {
                                    offset = value.location.x - 20
                                }
                            }
                            .onEnded { value in
                                switch value.location.x {
                                case 0...segments[0]:
                                    ratingState = .horrible
                                case segments[0]...segments[1]:
                                    ratingState = .notRecommend
                                case segments[1]...segments[2]:
                                    ratingState = .neutral
                                case segments[2]...segments[3]:
                                    ratingState = .recommend
                                case segments[3]...segments[4]:
                                    ratingState = .amazing
                                default:
                                    print("💀 not in the range")
                                    break
                                }
                            }
                    )
            }
        }
    }

    func calculateSegments() -> [CGFloat]{
        var segments: [CGFloat] = []

        for i in 1..<6 {
            segments.append((width/5) * CGFloat(i))
        }

        return segments
    }

    enum Rating {
        case horrible
        case notRecommend
        case neutral
        case recommend
        case amazing
    }
}

struct SearchResultDetailView_Previews: PreviewProvider {
    static var previews: some View {
//        StatefulPreviewWrapper(NavigationPath()) { SearchResultDetailView(movie: MovieMocks().generateMovies(count: 1).results[0]!, path: $0) }
        RatingSheet()
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
