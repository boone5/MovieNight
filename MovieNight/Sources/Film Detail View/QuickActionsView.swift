//
//  QuickActionsView.swift
//  MovieNight
//
//  Created by Boone on 8/2/25.
//

import SwiftUI

struct QuickActionsView: View {
    let mediaType: MediaType
    let averageColor: Color

    private let movieActions: [QuickAction] = [
        .location, .watchCount, .watchedWith, .occasion
    ]

    private let tvShowActions: [QuickAction] = [
        .seasonsWatched, .watchedWith, .favoriteSeason, .favoriteEpisode
    ]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                switch mediaType {
                case .movie:
                    ForEach(movieActions, id: \.self) { action in
                        ActionView(action: action, averageColor: averageColor)
                    }
                case .tvShow:
                    ForEach(tvShowActions, id: \.self) { action in
                        ActionView(action: action, averageColor: averageColor)
                    }
                }
            }
        }
    }

    struct ActionView: View {
        let action: QuickAction
        let averageColor: Color

        var body: some View {
            VStack {
                Circle()
                    .foregroundStyle(averageColor.opacity(0.4))
                    .frame(width: 60, height: 60)
                    .overlay {
                        action.image
                            .foregroundStyle(.white).opacity(0.6)
                    }

                Text(action.title)
                    .foregroundStyle(.white)
                    .font(.system(size: 12))
            }
        }
    }

    enum QuickAction {
        case location
        case watchCount
        case watchedWith
        case occasion
        case seasonsWatched
        case favoriteSeason
        case favoriteEpisode

        public var title: String {
            switch self {
            case .location:
                "Where"
            case .watchCount:
                "Times"
            case .watchedWith:
                "With"
            case .occasion:
                "Occasion"
            case .seasonsWatched:
                "Progress"
            case .favoriteSeason:
                "Season"
            case .favoriteEpisode:
                "Episode"
            }
        }

        public var image: some View {
            switch self {
            case .location:
                Image(systemName: "mappin.and.ellipse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)

            case .watchCount:
                Image(systemName: "plus.square.on.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)

            case .watchedWith:
                Image(systemName: "person.2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)

            case .occasion:
                Image(systemName: "gift")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)

            case .seasonsWatched:
                Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)

            case .favoriteSeason:
                Image(systemName: "heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)

            case .favoriteEpisode:
                Image(systemName: "heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
            }
        }
    }
}
