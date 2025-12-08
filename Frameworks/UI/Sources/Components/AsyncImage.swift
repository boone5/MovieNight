//
//  AsyncImage.swift
//  Frameworks
//
//  Created by Ayren King on 12/8/25.
//

import Dependencies
import Networking
import SwiftUI

public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    @Dependency(\.imageLoader) private var loader

    private let path: String?
    private let content: (UIImage) -> Content
    private let placeholder: () -> Placeholder

    @State private var phase: Phase = .loading

    public init(
        _ path: String?,
        @ViewBuilder content: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.path = path
        self.content = content
        self.placeholder = placeholder
    }

    private enum Phase {
        case loading
        case success(UIImage)
        case failure
    }

    public var body: some View {
        Group {
            switch phase {
            case .loading:
                placeholder()

            case .success(let image):
                content(image)

            case .failure:
                placeholder()
            }
        }
        .task(id: path) {
            await load()
        }
    }

    @MainActor
    private func load() async {
        guard let path else {
            phase = .failure
            return
        }

        do {
            if let image = try await loader.loadImage(path) {
                phase = .success(image)
            } else {
                phase = .failure
            }
        } catch {
            phase = .failure
        }
    }
}
