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
    @Environment(\.imageLoader) private var imageLoader
    @ObservedObject var viewModel: ThumbnailView.ViewModel
    @Dependency(\.movieProvider) var movieProvider

    @State private var uiImage: UIImage?

    let filmID: Int64
    let posterPath: String?
    let width: CGFloat
    let height: CGFloat
    let namespace: Namespace.ID

    @State private var feedback: Feedback? = nil

    public init(
        viewModel: ThumbnailView.ViewModel,
        uiImage: UIImage? = nil,
        filmID: Int64,
        posterPath: String?,
        width: CGFloat,
        height: CGFloat,
        namespace: Namespace.ID
    ) {
        self.viewModel = viewModel
        self.uiImage = uiImage
        self.filmID = filmID
        self.posterPath = posterPath
        self.width = width
        self.height = height
        self.namespace = namespace
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 8)
                .matchedGeometryEffect(id: "background" + String(filmID), in: namespace)
                .foregroundStyle(.clear)
                .frame(width: width, height: height)

            PosterView(
                width: width,
                height: height,
                uiImage: uiImage,
                filmID: filmID,
                namespace: namespace,
                isAnimationSource: true
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
        .task {
            if let posterPath {
                await loadImage(url: posterPath)
            }

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

    private func loadImage(url: String?) async {
        guard let url else { return }

        do {
            guard let data = try await imageLoader.load(url) else { return }
            viewModel.imageMap[url] = data
            uiImage = UIImage(data: data)
        } catch {
            print("⛔️ Error loading image: \(error)")
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
    let width: CGFloat
    let height: CGFloat
    let uiImage: UIImage?
    let filmID: Int64
    let namespace: Namespace.ID
    let isAnimationSource: Bool

    var body: some View {
        if let uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .matchedGeometryEffect(id: "thumbnail" + String(filmID), in: namespace, isSource: isAnimationSource)
                .frame(width: width, height: height)
                .scaledToFit()
        } else {
            RoundedRectangle(cornerRadius: 8)
                .matchedGeometryEffect(id: "thumbnail" + String(filmID), in: namespace)
                .frame(width: width, height: height)
                .foregroundStyle(.gray)
        }
    }
}

public extension ThumbnailView {
    class ViewModel: ObservableObject {
        public init() {}

        public var imageMap: [String: Data] = [:]

        public func posterImage(for posterPath: String?) -> UIImage? {
            guard let posterPath else { return nil}

            if let data = imageMap[posterPath] {
                return UIImage(data: data)
            } else {
                return nil
            }
        }
    }
}
