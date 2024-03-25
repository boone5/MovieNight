//
//  TVShowDetailScreen.swift
//  MovieNight
//
//  Created by Boone on 3/24/24.
//

import SwiftUI

struct TVShowDetailScreen: View {
    @ObservedObject var viewModel: TVShowDetailViewModel

    @Binding var path: NavigationPath

    @State private var showRatingSheet = false
    @State private var localRating: Int16 = 0
    @State private var didReview: Bool = false
    @State private var storedRating: Int16?

    var body: some View {
        ZStack {
            Color.clear
                .background {
                    LinearGradient(colors: [Color("BackgroundColor1"), Color("BackgroundColor2")], startPoint: .top, endPoint: .bottom)
                }
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        if let image = makeUIImage() {
                            Image(uiImage: image)
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

                        Text(viewModel.tvShow.title)
                            .frame(maxWidth: 300)
                            .multilineTextAlignment(.center)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.top, 15)

                        Group {
                            if let storedRating {
                                ZStack {
                                    Rectangle()
                                        .frame(width: 100, height: 35)
                                        .frame(maxHeight: .infinity)
                                        .foregroundStyle(Color("BrightRed"))
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)

                                    HStack {
                                        Text(String(storedRating))
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
                            } else {
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

                        Text(viewModel.tvShow.overview)
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
                                ForEach(viewModel.recommendedTVShows) { movie in
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
        .task {
            await viewModel.fetchAddtionalDetails()
        }
    }

    private func makeUIImage() -> UIImage? {
        guard let data = ImageCache.shared.getObject(forKey: viewModel.tvShow.posterPath) else { return nil }

        return UIImage(data: data)
    }

    private func onSheetDismiss() {
        if didReview {
            let id = viewModel.tvShow.id

            // MARK: TODO - Need to create new core data object for each content type (Movie, TV Show, Person). ID: 59941 is the same for a TV Show and Person on the API
            guard let existing = MovieProvider.shared.exists(id: id) else {
                print("ℹ️ Movie doesn't exist in Core Data. Creating new object.")

                let movieDetails = Movie_CD(context: MovieProvider.shared.viewContext)
                movieDetails.posterData = nil
                movieDetails.userRating = localRating
                movieDetails.id = id

//                MovieProvider.shared.save()

                self.didReview = true
                self.storedRating = localRating

                return
            }

            MovieProvider.shared.update(entity: existing, userRating: localRating)
        } else {
            print("ℹ️ No review was submitted; no data will be saved.")
        }
    }
}

//#Preview {
//    TVShowDetailScreen()
//}
