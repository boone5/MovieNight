//
//  ThumbnailView.swift
//  MovieNight
//
//  Created by Boone on 12/12/24.
//

import SwiftUI

struct ThumbnailView: View {
    @Environment(\.imageLoader) private var imageLoader
    @ObservedObject var viewModel: ThumbnailView.ViewModel

    @State private var uiImage: UIImage?

    let filmID: Int64
    let posterPath: String?
    let width: CGFloat = 175
    let height: CGFloat = 250
    let namespace: Namespace.ID

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 15)
                .matchedGeometryEffect(id: "background" + String(filmID), in: namespace)
                .foregroundStyle(.clear)
                .frame(width: 175, height: 250)

            PosterView(uiImage: uiImage, filmID: filmID, namespace: namespace, isAnimationSource: true)

            Circle()
                .matchedGeometryEffect(id: "info" + String(filmID), in: namespace)
                .frame(width: 50, height: 20)
                .foregroundStyle(.clear)
                .padding([.bottom, .trailing], 15)
        }
        .task {
            if let posterPath {
                await loadImage(url: posterPath)
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

struct PosterView: View {
    let width: CGFloat
    let height: CGFloat
    let uiImage: UIImage?
    let filmID: Int64
    let namespace: Namespace.ID
    let isAnimationSource: Bool

    init(uiImage: UIImage?, filmID: Int64, namespace: Namespace.ID, isAnimationSource: Bool, width: CGFloat = 175, height: CGFloat = 250) {
        self.uiImage = uiImage
        self.filmID = filmID
        self.namespace = namespace
        self.isAnimationSource = isAnimationSource
        self.width = width
        self.height = height
    }

    var body: some View {
        if let uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .matchedGeometryEffect(id: "thumbnail" + String(filmID), in: namespace, isSource: isAnimationSource)
                .frame(width: width, height: height)
                .scaledToFit()
        } else {
            RoundedRectangle(cornerRadius: 15)
                .matchedGeometryEffect(id: "thumbnail" + String(filmID), in: namespace)
                .frame(width: width, height: height)
                .foregroundStyle(.gray)
        }
    }
}

extension ThumbnailView {
    class ViewModel: ObservableObject {
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
