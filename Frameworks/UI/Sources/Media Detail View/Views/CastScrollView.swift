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
    let cast: [CastCredit]

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

        let actor: CastCredit

        var body: some View {
            // TODO: Remove Background Image
            // TODO: Open Detail Modal on tap
            VStack(spacing: 4) {
                CachedAsyncImage(actor.person.profilePath) { image in
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
                Text(actor.person.name)
                    .font(.openSans(size: 12, weight: .regular))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 70, height: 34, alignment: .top)
                    .allowsTightening(true)
            }
        }
    }
}
