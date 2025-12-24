//
//  CastScrollView.swift
//  MovieNight
//
//  Created by Boone on 5/14/25.
//

import Dependencies
import Models
import Networking
import SwiftUI

struct CastScrollView: View {
    let averageColor: Color
    let cast: [PersonResponse]

    @State var uiImage: UIImage? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cast")
                .font(.montserrat(size: 16, weight: .semibold))
                .foregroundStyle(.white)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(cast, id: \.id) { actor in
                        ActorProfileView(actor: actor)
                    }
                }
                .frame(height: 140)
                .padding([.horizontal], 30)
            }
            .scrollIndicators(.hidden)
            .padding([.horizontal], -30)
        }
        .padding(20)
        .background(averageColor.opacity(0.4))
        .cornerRadius(12)
    }

    struct ActorProfileView: View {
        @Dependency(\.imageLoader) private var imageLoader
        @State private var uiImage: UIImage? = nil

        let actor: PersonResponse

        var body: some View {
            // TODO: Remove Background Image
            // TODO: Open Detail Modal on tap
            VStack(spacing: 4) {
                CachedAsyncImage(actor.profilePath) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 100)
                        .clipShape(.rect(cornerRadius: 8))
                        .shadow(radius: 3, y: 4)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.cinemaGray.opacity(0.3))
                        .frame(width: 60, height: 100)
                }
                Text(actor.name)
                    .font(.openSans(size: 12, weight: .regular))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 70, height: 34, alignment: .top)
                    .allowsTightening(true)
            }
            .task {
                await loadImage(url: actor.profilePath)
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
}

#Preview {
    _ = prepareDependencies {
        $0.imageLoader = ImageLoaderClient.liveValue
    }
    return CastScrollView(averageColor: .red, cast: [
        PersonResponse(id: 0, adult: nil, name: "Samuel L. Jackson", originalName: nil, mediaType: .person, popularity: nil, gender: nil, knownForDepartment: nil, profilePath: "/hFt7Cj8sx1VYIwm18lYmq5kS7Pw.jpg", character: nil, knownFor: []),
        PersonResponse(id: 1, adult: nil, name: "Micheal Cera", originalName: nil, mediaType: .person, popularity: nil, gender: nil, knownForDepartment: nil, profilePath: "/hFt7Cj8sx1VYIwm18lYmq5kS7Pw.jpg", character: nil, knownFor: []),
        PersonResponse(id: 2, adult: nil, name: "Sam Worthington", originalName: nil, mediaType: .person, popularity: nil, gender: nil, knownForDepartment: nil, profilePath: "/hFt7Cj8sx1VYIwm18lYmq5kS7Pw.jpg", character: nil, knownFor: [])
    ])
    .loadCustomFonts()
}
