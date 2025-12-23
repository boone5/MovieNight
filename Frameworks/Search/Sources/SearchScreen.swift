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
                    film: item,
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
    let film: any DetailViewRepresentable
    let namespace: Namespace.ID

    let action: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            ThumbnailView(
                filmID: film.id,
                posterPath: film.posterPath,
                size: .init(width: 80, height: 120),
                transitionConfig: .init(namespace: namespace, source: film)
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(film.title ?? "")
                    .font(.openSans(size: 16, weight: .medium))

                Text(film.mediaType.title)
                    .font(.openSans(size: 14, weight: .regular))
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

#Preview {
    SearchScreen(store: Store(initialState: SearchFeature.State(), reducer: SearchFeature.init))
}
