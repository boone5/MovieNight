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
    @Namespace var highlightNamespace

    public var body: some View {
        NavigationStack {
            BackgroundColorView {
                switch store.loadingState {
                case .idle:
                    NoSearchContentView()
                case .loading:
                     LoadingIndicator(color: .white, speed: 0.4)
                case .paginated:
                    SearchContentResultView(store: store, highlightNamespace: highlightNamespace)
                default:
                    EmptyView()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .searchable(text: $store.searchText)
            .scrollDismissesKeyboard(.immediately)
            .toolbar(store.isHighlightingResult ? .hidden : .visible, for: .tabBar)
            .opacity(store.isHighlightingResult ? 0 : 1)
            .overlay {
                if let selectedFilm = store.highlightedFilm {
                    FilmDetailView(
                        film: selectedFilm.film,
                        namespace: highlightNamespace
                    ) {
                        store.send(.view(.overlayDismissed))
                    }
                    .transition(.asymmetric(insertion: .identity, removal: .opacity))
                }
            }
            .onChange(of: store.loadingState) {
                print(store.loadingState)
            }
        }
    }
}

private struct NoSearchContentView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("What's Pop'n?")
                .font(.title3.bold())

            Text("Find your next movie, tv show, friend, or favorite cast member.")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 15)
    }
}

private struct SearchContentResultView: View {
    let store: StoreOf<SearchFeature>
    let highlightNamespace: Namespace.ID

    @Dependency(\.imageLoader) var imageLoader

    var body: some View {
        List {
            PaginatedContent(items: store.queryResults) { item in
                ResultRow(
                    film: item,
                    namespace: highlightNamespace,
                    isHighlighted: store.highlightedFilm?.id == item.id
                ) {
                    store.send(.view(.rowTapped(item, imageLoader.cachedImage(item.posterPath))))
                }
                .listRowBackground(Color.clear)
                .buttonStyle(PlainButtonStyle())
            } onLoadMore: {
                store.send(.api(.fetchResults))
            }

            if store.loadingState.completedPagination {
                NoMoreResultsView()
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .overlay {
            if store.queryResults.isEmpty && !store.searchText.isEmpty {
                ContentUnavailableView {
                    Label("We couldn't find any results for \"\(store.searchText)\"", systemImage: "xmark.circle")
                } description: {
                    Text("Try searching for something else.")
                }
            }
        }
    }
}

private struct ResultRow: View {
    let film: DetailViewRepresentable
    let namespace: Namespace.ID
    let isHighlighted: Bool

    let action: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            ThumbnailView(
                filmID: film.id,
                posterPath: film.posterPath,
                width: 80,
                height: 120,
                namespace: namespace,
                isHighlighted: isHighlighted
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(film.title ?? "")
                    .font(.system(size: 16, weight: .medium))

                Text(film.mediaType.title)
                    .font(.system(size: 14, weight: .regular))
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
            .font(.callout)
            .foregroundStyle(.secondary)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .opacity(appeared ? 1 : 0)
            .animation(.easeIn(duration: 0.25), value: appeared)
            .onAppear { appeared = true }
    }
}
