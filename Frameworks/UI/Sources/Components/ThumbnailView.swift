//
//  ThumbnailView.swift
//  MovieNight
//
//  Created by Boone on 12/12/24.
//

import Dependencies
import Models
import Networking
import SwiftUI

public struct ThumbnailView: View {
    @Dependency(\.movieProvider) var movieProvider

    let media: any DetailViewRepresentable
    let size: CGSize
    let transitionConfig: NavigationTransitionConfiguration<Film.ID>

    @State private var feedback: Feedback? = nil

    public init(
        media: any DetailViewRepresentable,
        size: CGSize,
        transitionConfig: NavigationTransitionConfiguration<Film.ID>
    ) {
        self.media = media
        self.size = size
        self.transitionConfig = transitionConfig
    }

    public var body: some View {
        PosterView(imagePath: media.posterPath, size: size)
            .overlay(alignment: .bottomLeading) {
                if let feedback {
                    FeedbackOverlayView(feedback: feedback)
                }
            }
            .zoomSource(configuration: transitionConfig)
            .shadow(radius: 3, y: 4)

            // Uncomment if using button
            //            Circle()
            //                .matchedGeometryEffect(id: "info" + String(filmID), in: namespace)
            //                .frame(width: 50, height: 20)
            //                .foregroundStyle(.clear)
            //                .padding([.bottom, .trailing], 15)
            .task(id: "loadFeedback") {
                guard media.mediaType != .person else { return }

                if let film = movieProvider.fetchFilm(media.id) {
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

struct FeedbackOverlayView: View {
    let feedback: Feedback

    var body: some View {
        Image(systemName: feedback.imageName)
            .renderingMode(.template)
            .resizable()
            .frame(width: 18, height: 18)
            .foregroundStyle(feedback.color)
            .padding(8)
            .background {
                feedback.color
                    .opacity(0.2)
                    .glassEffect(.clear)
            }
            .clipShape(Circle())
            .padding(8)
    }
}

struct PosterView: View {
    let imagePath: String?
    let size: CGSize

    var imageShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 8)
    }

    @Dependency(\.imageLoader.cachedImage) var cachedImage

    var body: some View {
        Group {
            if let cachedImage = cachedImage(imagePath) {
                Image(uiImage: cachedImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(imageShape)
            } else {
                CachedAsyncImage(imagePath) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(imageShape)
                } placeholder: {
                    imageShape
                        .foregroundStyle(.gray)
                        .frame(width: size.width, height: size.height)
                }
            }
        }
        .frame(width: size.width)
    }
}
