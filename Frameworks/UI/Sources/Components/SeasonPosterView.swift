//
//  SeasonPosterView.swift
//  MovieNight
//
//  Created by Boone on 2/25/25.
//

import Dependencies
import Networking
import SwiftUI

#Preview {
    SeasonPosterView(posterPath: nil, seasonNum: 1, averageColor: .red)
}

struct SeasonPosterView: View {
    @Dependency(\.imageLoader) private var imageLoader

    @State private var isWatched: Bool = false

    let posterPath: String?
    let seasonNum: Int
    let averageColor: Color
    var didToggle: ((Bool) -> Void)? = nil

    let size: CGSize = CGSize(width: 100, height: 150)

    var body: some View {
        CachedAsyncImage(posterPath) { image in
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipShape(.rect(cornerRadius: 8))
                .shadow(radius: 3, y: 4)
        } placeholder: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cinemaGray.opacity(0.3))
                .frame(width: size.width, height: size.height)
        }
        .overlay(alignment: .center) {
            VStack {
                Image(systemName: isWatched ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(averageColor)

                Text("Season \(seasonNum)")
                    .font(.openSans(size: 14, weight: .regular))
                    .foregroundStyle(.white)
            }
        }
        .onTapGesture {
            isWatched.toggle()
            didToggle?(isWatched)
        }
    }
}
