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
            .fullScreenCover(item: $store.selectedItem) { item in
                MediaDetailView(
                    media: item,
                    navigationTransitionConfig: .init(namespace: transitionNamespace, source: item),
                )
            }
        }
    }
}

#Preview {
    SearchScreen(store: Store(initialState: SearchFeature.State(), reducer: SearchFeature.init))
}
