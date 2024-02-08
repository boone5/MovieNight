//
//  Library.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import SwiftUI

struct Library: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: Details_CD.all(), animation: .default) private var movies: FetchedResults<Details_CD>

    @State private var path: NavigationPath = NavigationPath()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10, alignment: .center), count: 2)

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(.vertical) {
                // Move to LazyHStack if performance becomes an issue
                // https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(movies, id: \.id) { movie in
                        NavigationLink(value: movie) {
                            MovieGridItem(userRating: movie.userRating, imgData: movie.posterData)
                        }
                    }
                }
                .navigationDestination(for: Details_CD.self) { details in
                    MovieDetailView(path: $path, viewModel: .init(details: details))
                }
                .padding([.leading, .trailing, .top], 20)
                .navigationTitle("Library")
            }
        }
    }
}

struct MovieGridItem: View {
    let userRating: Int16
    let imgData: Data?

    var body: some View {
        if let imgData = imgData, let uiimage = UIImage(data: imgData) {
            Image(uiImage: uiimage)
                .resizable()
                .frame(width: 175, height: 240)
                .scaledToFit()
                .cornerRadius(15)
                .overlay(alignment: .bottom) {
                    ZStack {
                        Rectangle()
                            .frame(height: 50)
                            .cornerRadius(15)

                        HStack {
                            Text(String(userRating))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            Image(systemName: "star.fill")
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    }
                }
        }
    }

    struct RatingsPill: View {
        var body: some View {
            ZStack {
                Rectangle()
                    .frame(height: 50)
                    .cornerRadius(15)

                HStack {
                    Text("4")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Image(systemName: "star.fill")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
            }
        }
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}
