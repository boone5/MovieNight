//
//  CastScrollView.swift
//  MovieNight
//
//  Created by Boone on 5/14/25.
//

import SwiftUI

struct CastScrollView: View {
    let averageColor: UIColor
    let cast: [ActorResponse.Actor]

    @State var uiImage: UIImage? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cast")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(cast, id: \.id) { actor in
                        ActorProfileView(actor: actor)
                    }
                }
                .padding([.horizontal], 30)
            }
            .scrollIndicators(.hidden)
            .padding([.horizontal], -30)
            .frame(height: 100) // profileView height + name height
        }
        .padding(20)
        .background(Color(uiColor: averageColor).opacity(0.4))
        .cornerRadius(12)
    }

    struct ActorProfileView: View {
        @Environment(\.imageLoader) private var imageLoader
        @State private var uiImage: UIImage? = nil

        let actor: ActorResponse.Actor

        var body: some View {
            // TODO: Remove Background Image
            // TODO: Open Detail Modal on tap
            VStack(spacing: 0) {
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .frame(width: 70, height: 70)
                        .foregroundStyle(Color(uiColor: .systemGray4))
                }

                Text(actor.nameAdjusted)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 70, height: 30)
            }
            .task {
                await loadImage(url: actor.profilePath)
            }
        }

        private func loadImage(url: String?) async {
            guard let url else { return }

            do {
                guard let data = try await imageLoader.load(url) else { return }
                uiImage = UIImage(data: data)
            } catch {
                print("⛔️ Error loading image: \(error)")
            }
        }
    }
}

#Preview {
    CastScrollView(averageColor: .red, cast: [
        ActorResponse.Actor.init(id: 0, adult: nil, name: "Hello Worldd", originalName: nil, mediaType: nil, popularity: nil, gender: nil, knownForDepartment: nil, profilePath: nil, character: nil),
        ActorResponse.Actor.init(id: 0, adult: nil, name: "Hello Worldd", originalName: nil, mediaType: nil, popularity: nil, gender: nil, knownForDepartment: nil, profilePath: nil, character: nil)
    ])
}
