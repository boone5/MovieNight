//
//  SearchContentResultView.swift
//  Frameworks
//
//  Created by Ayren King on 12/28/25.
//

import ComposableArchitecture
import SwiftUI
import UI

struct SearchContentResultView: View {
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
