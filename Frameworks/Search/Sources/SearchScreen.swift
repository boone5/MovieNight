//
//  Search.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import ComposableArchitecture
import Models
import SwiftUI
import UI

enum SearchState {
    case explore
    case results
}

public struct SearchScreen: View {
    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }

    @Bindable private var store: StoreOf<SearchFeature>
    @Namespace var transitionNamespace

    @Environment(\.colorScheme) var colorScheme

    public var body: some View {
        NavigationStack {
            BackgroundColorView {
                switch store.loadingState {
                case .idle:
                    NoSearchContentView()
                case .loading:
                    LoadingIndicator(color: colorScheme == .dark ? .white : .black, speed: 0.4)
                case .paginated:
                    SearchContentResultView(store: store, transitionNamespace: transitionNamespace)
                default:
                    EmptyView()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .searchable(text: $store.searchText)
            .scrollDismissesKeyboard(.immediately)
            .fullScreenCover(item: $store.selectedFilm) { film in
                FilmDetailView(
                    film: film.film,
                    navigationTransitionConfig: .init(namespace: transitionNamespace, source: film.film),
                )
            }
        }
    }
}

private struct NoSearchContentView: View {

    var body: some View {
        VStack(spacing: 10) {
            Text("What's Pop'n?")
                .font(.montserrat(size: 24, weight: .semibold))

            Text("Find your next movie, tv show, friend, or favorite cast member.")
                .font(.openSans(size: 16))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 15)
    }
}

private struct SearchContentResultView: View {
    let store: StoreOf<SearchFeature>
    let transitionNamespace: Namespace.ID

    var body: some View {
        List {
            PaginatedContent(items: store.queryResults) { item in
                ResultRow(
                    media: item,
                    namespace: transitionNamespace
                ) {
                    store.send(.view(.rowTapped(item)))
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .buttonStyle(PlainButtonStyle())

            } onLoadMore: {
                store.send(.api(.fetchResults))
            }

            if store.loadingState.completedPagination, !store.queryResults.isEmpty {
                NoMoreResultsView()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .overlay {
            if store.queryResults.isEmpty && !store.searchText.isEmpty {
                ContentUnavailableView {
                    Label("We couldn't find any results for \"\(store.searchText)\"", systemImage: "xmark.circle")
                        .font(.montserrat(size: 18, weight: .bold))
                } description: {
                    Text("Try searching for something else.")
                        .font(.openSans(size: 14, weight: .semibold))
                }
            }
        }
    }
}

private struct ResultRow: View {
    let media: MediaResult
    let namespace: Namespace.ID

    let action: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            ThumbnailView(
                media: media,
                size: .init(width: 80, height: 120),
                transitionConfig: .init(namespace: namespace, source: media)
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(media.title)
                    .font(.montserrat(size: 16, weight: .semibold))
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)

                switch media {
                case .movie, .tv:
                    if let overview = media.overview {
                        Text(overview)
                            .font(.openSans(size: 12, weight: .regular))
                            .lineLimit(2)
                            .clipped()
                            .multilineTextAlignment(.leading)
                    }
                case .person(let person):
                    HStack(spacing: 2) {
                        if let knownForDepartment = person.knownForDepartment {
                            Text(knownForDepartment)
                                .font(.openSans(size: 12, weight: .semibold))

                            if person.knownFor?.isEmpty == false {
                                Text("•")
                                    .font(.openSans(size: 12, weight: .semibold))
                            }
                        }

                        if let knownFor = person.knownFor?.first {
                            Text(knownFor.title)
                                .font(.openSans(size: 12, weight: .regular))
                        }
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .truncationMode(.tail)
                }

                Text(media.mediaType.title)
                    .font(.openSans(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .clipShape(.capsule)
                    .frame(width: 50)
                    .background {
                        Capsule()
                            .fill(media.mediaType.color.opacity(0.85))
                            .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                    }

            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring()) {
                action()
            }
        }
        .padding(.vertical, 5)
    }
}

private struct NoMoreResultsView: View {
    @State private var appeared = false

    var body: some View {
        Text("No more results")
            .font(.openSans(size: 14, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .opacity(appeared ? 1 : 0)
            .animation(.easeIn(duration: 0.25), value: appeared)
            .onAppear { appeared = true }
    }
}

extension MediaType {
    var color: Color {
        switch self {
        case .movie: Color.goldPopcorn
        case .tv: Color.popRed
        case .person: Color.card
        }
    }
}

#Preview {
    SearchScreen(store: Store(initialState: SearchFeature.State(), reducer: SearchFeature.init))
}
