//
//  ThumbnailView.swift
//  MovieNight
//
//  Created by Boone on 2/4/24.
//

import SwiftUI

struct ThumbnailView: View {
    @Environment(\.imageLoader) private var imageLoader
    @State private var uiimage: UIImage?

    let url: String?
    let id: Int64
    let width: CGFloat
    let height: CGFloat

    let namespace: Namespace.ID

    var body: some View {
        Group {
            if let uiimage {
                Image(uiImage: uiimage)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .matchedGeometryEffect(id: "thumbnail" + String(id), in: namespace)
                    .frame(width: width, height: height)
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 15)
                    .matchedGeometryEffect(id: "thumbnail" + String(id), in: namespace)
                    .frame(width: width, height: height)
                    .foregroundStyle(.gray)
            }
        }
        .task {
            await loadImage(url: url)
        }
    }

    private func loadImage(url: String?) async {
        do {
            guard let data = try await imageLoader.load(url) else { return }
            uiimage = UIImage(data: data)
        } catch {
            print("⛔️ Error loading image: \(error)")
        }
    }
}

struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue = ImageLoader()
}

extension EnvironmentValues {
    var imageLoader: ImageLoader {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self ] = newValue}
    }
}

//#Preview {
//    ThumbnailView(url: nil, width: 100, height: 150)
//}
