//
//  MediaDetailView.swift
//  MovieNight
//
//  Created by Boone on 10/1/24.
//

import CoreData
import Dependencies
import Models
import Networking
import SwiftUI
import YouTubePlayerKit

// MARK: FilmDetailView

public struct MediaDetailView: View {
    @Environment(\.dismiss) var dismiss

    @State var viewModel: MediaDetailViewModel
    let navigationTransitionConfig: NavigationTransitionConfiguration<MediaItem.ID>
    let posterSize: CGSize

    @State private var actionTapped: QuickAction?
    @State private var watchCount = 0

    public init(
        media: MediaItem,
        navigationTransitionConfig: NavigationTransitionConfiguration<MediaItem.ID>,
    ) {
        _viewModel = State(wrappedValue: MediaDetailViewModel(media: media))
        self.navigationTransitionConfig = navigationTransitionConfig

        let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.size ?? .zero
        self.posterSize = CGSize(width: size.width / 1.5, height: size.height / 2.4)
    }

    var averageColor: Color {
        viewModel.averageColor
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 30) {
                // MARK: TODO
                // - Add gloss finish
                PosterView(
                    imagePath: viewModel.media.posterPath,
                    size: posterSize
                )
                .shadow(radius: 6, y: 3)
                .shimmyingEffect()
                .safeAreaPadding(.top, 50)

                VStack(alignment: .center, spacing: 5) {
                    Text(viewModel.media.title)
                        .font(.montserrat(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    Text(viewModel.genres ?? "-")
                        .font(.openSans(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))

                    Text([viewModel.releaseYear, viewModel.duration].compactMap { $0 }.joined(separator: " · "))
                        .font(.openSans(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                }


                FeedbackButtons(feedback: $viewModel.feedback, averageColor: viewModel.averageColor) {
                    viewModel.addActivity(feedback: $0)
                }

                // TODO: Add "See more" button
                if let summary = viewModel.media.overview {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Summary")
                            .font(.montserrat(size: 16, weight: .semibold))
                            .foregroundStyle(.white)

                        Text(summary)
                            .font(.openSans(size: 14))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(averageColor.opacity(0.4))
                    .cornerRadius(12)
                }

                CommentPromptView(
                    averageColor: viewModel.averageColor,
                    comments: viewModel.media.comments ?? [],
                    didTapSave: { comment in
                        viewModel.addComment(text: comment)
                    }
                )

                QuickActionsView(
                    mediaType: viewModel.media.mediaType,
                    averageColor: viewModel.averageColor,
                    actionTapped: $actionTapped
                )

                if let actionTapped {
                    switch actionTapped {
                    case .collection:
                        ActionView(averageColor: averageColor) {
                            HStack {
                                Text(actionTapped.longTitle)
                                    .font(.openSans(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)

                                Spacer()

                                Label {
                                    Text("Add a collection")
                                        .font(.openSans(size: 14))
                                } icon: {
                                    Image(systemName: "plus")
                                        .font(.openSans(size: 14))
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 8)
                                .background(averageColor.opacity(0.4))
                                .cornerRadius(12)
                            }
                        }
                    case .location:
                        WatchedAtView(averageColor: viewModel.averageColor)
                    case .watchCount:
                        ActionView(averageColor: averageColor) {
                            HStack(spacing: 0) {
                                Text(actionTapped.longTitle + " \(watchCount) times")
                                    .font(.openSans(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)

                                Spacer()

                                CustomStepper(steps: 10, startStep: $watchCount)
                            }
                            .padding(.vertical, 10)
                        }
                    case .watchedWith:
                        ActionView(averageColor: averageColor) {
                            Text(actionTapped.longTitle)
                                .font(.openSans(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    case .occasion:
                        ActionView(averageColor: averageColor) {
                            Text(actionTapped.longTitle)
                                .font(.openSans(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    case .seasonsWatched:
                        ActionView(averageColor: averageColor) {
                            Text(actionTapped.longTitle)
                                .font(.openSans(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    case .favoriteSeason:
                        ActionView(averageColor: averageColor) {
                            Text(actionTapped.longTitle)
                                .font(.openSans(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    case .favoriteEpisode:
                        ActionView(averageColor: averageColor) {
                            Text(actionTapped.longTitle)
                                .font(.openSans(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }

                // V2 w/ Social Features
//                    ParticipantsView(averageColor: viewModel.averageColor)
//                        .padding(.top, 30)

                if case .tv = viewModel.media.mediaType {
                    SeasonsScrollView(viewModel: viewModel)
                }

                if let cast = viewModel.cast {
                    CastScrollView(averageColor: viewModel.averageColor, cast: cast)
                }

                if let trailer = viewModel.trailer, let key = trailer.key {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Trailer")
                            .font(.montserrat(size: 16, weight: .semibold))
                            .foregroundStyle(.white)

                        TrailerView(videoID: key)
                    }
                    .padding(20)
                    .background(averageColor.opacity(0.4))
                    .cornerRadius(12)
                }

                Spacer()
            }
            .padding(.vertical, 80)
            .padding(.horizontal, 20)
        }
        .background {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(
                    LinearGradient(
                        colors: [viewModel.averageColor, .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .top) {
            toolbar
        }
        .task(id: "fetchInitialData") {
            await viewModel.loadInitialData()
        }
        .zoomTransition(configuration: navigationTransitionConfig)
    }
}

extension MediaDetailView {
    private var toolbar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Label("Close", systemImage: "xmark")
                    .foregroundStyle(Color.ivoryWhite.opacity(0.8))
                    .labelStyle(.iconOnly)
                    .frame(width: 50, height: 50)
            }
            .glassEffect(.regular.tint(averageColor.opacity(0.8)).interactive(), in: .circle)

            Spacer()

            Menu {
                ForEach(viewModel.menuSections) { section in
                    ForEach(section.actions) { action in
                        Button(role: action.role == .destructive ? .destructive : nil) {
                            action.handler()
                        } label: {
                            Label(action.title, systemImage: action.systemImage)
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(Color.ivoryWhite.opacity(0.8))
                    .labelStyle(.iconOnly)
                    .frame(width: 50, height: 50)
                    .glassEffect(.regular.tint(averageColor.opacity(0.8)).interactive(), in: .circle)
                    .clipShape(.circle)
            }
        }
        .safeAreaPadding(.horizontal)
    }
}

// MARK: Preview

#Preview {
    @Previewable @Namespace var namespace

    let film: MediaItem = .init(from: .movie(MovieResponse()))
//    let film: ResponseType = ResponseType.tvShow(TVShowResponse())

    Text("FilmDetailView Preview")
        .fullScreenCover(isPresented: .constant(true)) {
            MediaDetailView(media: film, navigationTransitionConfig: .init(namespace: namespace, source: film))
                .loadCustomFonts()
        }
}
