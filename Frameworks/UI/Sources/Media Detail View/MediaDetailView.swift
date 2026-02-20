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

                    switch viewModel.media.mediaType {
                    case .movie:
                        if case let .movie(details)? = viewModel.details {
                            Text(details.genres ?? "-")
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                            Text([details.releaseYear, details.duration].compactMap { $0 }.joined(separator: " · "))
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                        } else {
                            Text("-")
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                        }
                    case .tv:
                        if case let .tv(details)? = viewModel.details {
                            Text(details.genres ?? "-")
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                            Text([details.releaseYear, details.duration].compactMap { $0 }.joined(separator: " · "))
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                        } else {
                            Text("-")
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                        }
                    case .person:
                        if case let .person(personDetails)? = viewModel.details {
                            Text(personDetails.knownForDepartment ?? "-")
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                        }
                    }
                }

                switch viewModel.media.mediaType {
                case .movie:
                    movieLayout()
                case .tv:
                    tvLayout()
                case .person:
                    if case let .person(details)? = viewModel.details {
                        personLayout(details)
                    } else {
                        Text("Uh oh")
                            .foregroundStyle(.white)
                        LoadingIndicator()
                    }
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
        .task {
            await viewModel.loadInitialData()
        }
        .sheet(isPresented: $viewModel.showAddToCollectionSheet) {
            AddToCollectionSheet(
                store: .init(
                    initialState: AddToCollectionFeature.State(media: viewModel.media, customBackgroundColor: viewModel.averageColor),
                    reducer: { AddToCollectionFeature()}
                )
            )
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

    @ViewBuilder
    private func movieLayout() -> some View {
        FeedbackButtons(
            feedback: $viewModel.media.feedback,
            averageColor: viewModel.averageColor
        ) { newFeedback in
            viewModel.addActivity(feedback: newFeedback)
        }

        if let summary = viewModel.media.overview {
            Card(averageColor: averageColor) {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Summary")
                        .font(.montserrat(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(summary)
                        .font(.openSans(size: 14))
                        .foregroundStyle(.white)
                        .truncationEffect(length: 5, isEnabled: !viewModel.showFullSummary, animation: .smooth(duration: 0.5, extraBounce: 0))

                    Button(viewModel.showFullSummary ? "Read less" : "Read more") {
                        viewModel.showFullSummary.toggle()
                    }
                    .font(.openSans(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }

        CommentPromptView(
            averageColor: viewModel.averageColor,
            comments: viewModel.media.comments ?? [],
            didTapSave: { comment in
                viewModel.addComment(text: comment)
            }
        )

        QuickActionsView(
            mediaType: .movie,
            averageColor: viewModel.averageColor,
            actionTapped: $viewModel.actionTapped
        )

        if let actionTapped = viewModel.actionTapped {
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
                        Text(actionTapped.longTitle + " \(viewModel.watchCount) times")
                            .font(.openSans(size: 16, weight: .semibold))
                            .foregroundStyle(.white)

                        Spacer()

                        CustomStepper(steps: 10, startStep: $viewModel.watchCount)
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
            case .seasonsWatched, .favoriteSeason, .favoriteEpisode:
                EmptyView()
            }
        }

        if case let .movie(details)? = viewModel.details, let cast = details.cast {
            CastScrollView(averageColor: viewModel.averageColor, cast: cast)
        }

        if case let .movie(details)? = viewModel.details, let trailer = details.trailer, let key = trailer.key {
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
    }

    @ViewBuilder
    private func tvLayout() -> some View {
        FeedbackButtons(
            feedback: $viewModel.media.feedback,
            averageColor: viewModel.averageColor
        ) { newFeedback in
            viewModel.addActivity(feedback: newFeedback)
        }

        if let summary = viewModel.media.overview {
            Card(averageColor: averageColor) {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Summary")
                        .font(.montserrat(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(summary)
                        .font(.openSans(size: 14))
                        .foregroundStyle(.white)
                        .truncationEffect(length: 5, isEnabled: !viewModel.showFullSummary, animation: .smooth(duration: 0.5, extraBounce: 0))

                    Button(viewModel.showFullSummary ? "Read less" : "Read more") {
                        viewModel.showFullSummary.toggle()
                    }
                    .font(.openSans(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }

        CommentPromptView(
            averageColor: viewModel.averageColor,
            comments: viewModel.media.comments ?? [],
            didTapSave: { comment in
                viewModel.addComment(text: comment)
            }
        )

        QuickActionsView(
            mediaType: .tv,
            averageColor: viewModel.averageColor,
            actionTapped: $viewModel.actionTapped
        )

        if let actionTapped = viewModel.actionTapped {
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
                        Text(actionTapped.longTitle + " \(viewModel.watchCount) times")
                            .font(.openSans(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        CustomStepper(steps: 10, startStep: $viewModel.watchCount)
                    }
                    .padding(.vertical, 10)
                }
            case .watchedWith, .occasion, .seasonsWatched, .favoriteSeason, .favoriteEpisode:
                ActionView(averageColor: averageColor) {
                    Text(actionTapped.longTitle)
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }

        if case let .tv(details)? = viewModel.details {
            SeasonsScrollView(viewModel: viewModel)
            if let cast = details.cast {
                CastScrollView(averageColor: viewModel.averageColor, cast: cast)
            }
            if let trailer = details.trailer, let key = trailer.key {
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
        }
    }

    @ViewBuilder
    private func personLayout(_ details: AdditionalDetailsPerson) -> some View {
        PersonDetailsView(details: details, averageColor: averageColor)

        QuickActionsView(
            mediaType: .person,
            averageColor: viewModel.averageColor,
            actionTapped: $viewModel.actionTapped
        )

        if let actionTapped = viewModel.actionTapped {
            ActionView(averageColor: averageColor) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(actionTapped.longTitle)
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("This action will be available soon.")
                        .font(.openSans(size: 13))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
    }
}

// MARK: Preview

#Preview {
    @Previewable @Namespace var namespace
    let item: MediaItem = .init(from: .movie(MovieResponse()))

    Text("FilmDetailView Preview")
        .fullScreenCover(isPresented: .constant(true)) {
            MediaDetailView(media: item, navigationTransitionConfig: .init(namespace: namespace, source: item))
                .loadCustomFonts()
        }
}
