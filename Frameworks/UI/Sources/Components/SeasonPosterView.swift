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
    
    @State private var uiImage: UIImage?
    @State private var isWatched: Bool = false

    let posterPath: String?
    let seasonNum: Int
    let averageColor: Color
    var didToggle: ((Bool) -> Void)? = nil

    var body: some View {
        ZStack {
            Group {
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .blur(radius: 3)
                        .overlay {
                            Color.black.opacity(0.5)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(width: 100, height: 150)
                        .scaledToFit()

                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 100, height: 150)
                }
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
        }
        .task {
            if let posterPath {
                await loadImage(url: posterPath)
            }
        }
        .onTapGesture {
            isWatched.toggle()
            didToggle?(isWatched)
        }
    }

    private func loadImage(url: String?) async {
        guard let url else { return }

        do {
            guard let image = try await imageLoader.loadImage(url) else { return }
            uiImage = image
        } catch {
            print("⛔️ Error loading image: \(error)")
        }
    }
}
