//
//  ThumbnailView.swift
//  MovieNight
//
//  Created by Boone on 12/12/24.
//

import Dependencies
import Networking
import SwiftUI

public struct ThumbnailView: View {
    @Dependency(\.movieProvider) var movieProvider

    let filmID: Int64
    let posterPath: String?
    let width: CGFloat
    let height: CGFloat
    let namespace: Namespace.ID

    let isHighlighted: Bool

    @State private var feedback: Feedback? = nil

    public init(
        filmID: Int64,
        posterPath: String?,
        width: CGFloat,
        height: CGFloat,
        namespace: Namespace.ID,
        isHighlighted: Bool
    ) {
        self.filmID = filmID
        self.posterPath = posterPath
        self.width = width
        self.height = height
        self.namespace = namespace
        self.isHighlighted = isHighlighted
    }

    public var body: some View {
        if isHighlighted {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.gray)
                .frame(width: width, height: height)
                .shadow(radius: 3, y: 4)
        } else {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .matchedGeometryEffect(id: "background" + String(filmID), in: namespace)
                    .foregroundStyle(.white.opacity(0.001))
                    .frame(width: width, height: height)

                PosterView(
                    imagePath: posterPath,
                    width: width,
                    height: height,
                    filmID: filmID,
                    namespace: namespace
                )
                .overlay(alignment: .bottomLeading) {
                    if let feedback {
                        FeedbackOverlayView(feedback: feedback)
                            .padding([.leading, .bottom], 10)
                    }
                }
                .shadow(radius: 3, y: 4)

                // Uncomment if using button
                //            Circle()
                //                .matchedGeometryEffect(id: "info" + String(filmID), in: namespace)
                //                .frame(width: 50, height: 20)
                //                .foregroundStyle(.clear)
                //                .padding([.bottom, .trailing], 15)
            }
            .task(id: "loadFeedback") {
                if let film = movieProvider.fetchFilm(filmID) {
                    if film.isLiked {
                        feedback = .like(enabled: true)
                    } else if film.isDisliked {
                        feedback = .dislike(enabled: true)
                    } else if film.isLoved {
                        feedback = .love(enabled: true)
                    }
                } else {
                    feedback = nil
                }
            }
        }
    }
}

struct FeedbackOverlayView: View {
    let feedback: Feedback

    var body: some View {
        Image(systemName: feedback.imageName)
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(feedback.color)
    }
}

struct PosterView: View {
    let imagePath: String?
    let width: CGFloat
    let height: CGFloat
    let filmID: Int64
    let namespace: Namespace.ID

    var imageShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 8)
    }

    @Dependency(\.imageLoader.cachedImage) var cachedImage

    var body: some View {
        Group {
            if let cachedImage = cachedImage(imagePath) {
                Image(uiImage: cachedImage)
                    .resizable()
                    .clipShape(imageShape)
                    .scaledToFit()
            } else {
                CachedAsyncImage(imagePath) { image in
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(imageShape)
                        .scaledToFit()
                } placeholder: {
                    imageShape
                        .foregroundStyle(.gray)
                }
            }
        }
        .matchedGeometryEffect(id: "thumbnail" + String(filmID), in: namespace)
        .frame(width: width, height: height)
    }
}
