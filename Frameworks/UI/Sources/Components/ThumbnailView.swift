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

    let media: MediaItem
    let size: CGSize
    let transitionConfig: NavigationTransitionConfiguration<MediaItem.ID>

    @State private var feedback: Feedback? = nil

    public init(
        media: MediaItem,
        size: CGSize,
        transitionConfig: NavigationTransitionConfiguration<MediaItem.ID>
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
            .task(id: "loadFeedback") {
                guard media.mediaType != .person else { return }

                guard media.feedback == nil else {
                    feedback = media.feedback
                    return
                }

                if let film = movieProvider.fetchFilm(media.id) {
                    feedback = film.feedback
                }
            }
    }
}

struct FeedbackOverlayView: View {
    let feedback: Feedback

    var body: some View {
        Image(systemName: feedback.imageName)
            .resizable()
            .symbolVariant(.fill)
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
