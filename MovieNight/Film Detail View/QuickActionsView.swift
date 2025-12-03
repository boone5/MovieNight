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
    @Binding var actionTapped: QuickAction?

    private let movieActions: [QuickAction] = [
        .collection, .location, .watchCount, .watchedWith, .occasion
    ]

    private let tvShowActions: [QuickAction] = [
        .collection, .seasonsWatched, .watchedWith, .favoriteSeason, .favoriteEpisode
    ]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                switch mediaType {
                case .movie:
                    ForEach(movieActions, id: \.self) { action in
                        ActionButton(action: action, averageColor: averageColor, actionTapped: $actionTapped)
                    }
                case .tvShow:
                    ForEach(tvShowActions, id: \.self) { action in
                        ActionButton(action: action, averageColor: averageColor, actionTapped: $actionTapped)
                    }
                }
            }
        }
    }

    private struct ActionButton: View {
        let action: QuickAction
        let averageColor: Color
        @Binding var actionTapped: QuickAction?

        var body: some View {
            VStack {
                Circle()
                    .foregroundStyle(averageColor.opacity(0.4))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Group {
                            switch action {
                            case .collection:
                                Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
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
                                Text("0%")
                                    .font(.system(size: 18, weight: .medium))
                                    .minimumScaleFactor(0.5)
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
                        .foregroundStyle(.white)
                    }

                Text(action.shortTitle)
                    .foregroundStyle(.white)
                    .font(.system(size: 12))
            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    if actionTapped != nil && actionTapped == action {
                        actionTapped = nil
                    } else {
                        actionTapped = action
                    }
                }
            }
        }
    }
}

enum QuickAction: Identifiable {
    case collection
    case location
    case watchCount
    case watchedWith
    case occasion
    case seasonsWatched
    case favoriteSeason
    case favoriteEpisode

    public var id: Self {
        self
    }

    public var shortTitle: String {
        switch self {
        case .collection:
            "Collection"
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

    public var longTitle: String {
        switch self {
        case .collection:
            "Collection"
        case .location:
            "Watched at"
        case .watchCount:
            "You've watched this"
        case .watchedWith:
            "You watched this with"
        case .occasion:
            "Occasion"
        case .seasonsWatched:
            "You're on season"
        case .favoriteSeason:
            "Favorite Season"
        case .favoriteEpisode:
            "Favorite Episode"
        }
    }
}
