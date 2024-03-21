//
//  Library.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import SwiftUI

struct Library: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: Movie_CD.all(), animation: .default) private var movies: FetchedResults<Movie_CD>

    @State private var path: NavigationPath = NavigationPath()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10, alignment: .center), count: 2)
    private let mocked = [MovieResponse.mockedData]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.clear
                    .background {
                        LinearGradient(colors: [Color("BackgroundColor1"), Color("BackgroundColor2")], startPoint: .top, endPoint: .bottom)
                    }
                    .ignoresSafeArea()

                VStack {
                    Text("Library")
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .top], 20)

                    ScrollView(.vertical) {
                        // Move to LazyHStack if performance becomes an issue
                        // https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(mocked, id: \.id) { movie in
                                NavigationLink(value: movie) {
                                    MovieGridItem(userRating: movie.userRating, imgData: movie.posterData)
                                }
                            }
                        }
                        .navigationDestination(for: Movie_CD.self) { movie in
                            MovieDetailView(path: $path, imgData: movie.posterData, movieID: movie.id)
                        }
                        .padding([.leading, .trailing, .top], 20)
                    }
                }
            }

        }
    }
}

struct MovieGridItem: View {
    let userRating: Int16
    let imgData: Data?

    var body: some View {
        VStack(spacing: 10) {
            RatingCapsuleView(userRating: userRating)

            if let imgData = imgData, let uiimage = UIImage(data: imgData) {
                Image(uiImage: uiimage)
                    .resizable()
                    .frame(width: 175, height: 240)
                    .scaledToFit()
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
            } else {
                Rectangle()
                    .frame(width: 175, height: 240)
                    .cornerRadius(15)
            }
        }
    }

    struct RatingCapsuleView: View {
        let userRating: Int16

        var body: some View {
            ZStack {
                ButtonView()

                HStack {
                    ForEach(1..<6) { index in
                        let isEnabled = index <= userRating

                        if isEnabled {
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color("Gold"))
                                .shadow(color: Color("Gold").opacity(0.5), radius: 6)
                        } else {
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                        }
                    }

                }
            }
        }
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}
