//
//  SearchFeature.swift
//  Search
//
//  Created by Ayren King on 12/5/25.
//

import ComposableArchitecture
import Models
import Networking
import SwiftUI
import UI

@Reducer
public struct SearchFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public init() {}

        var searchText: String = ""
        var loadingState: LoadingState = .idle

        var queryResults: [ResponseType] = []

        @Presents var selectedFilm: SelectedFilm?
    }

    public enum Action: ViewAction, Equatable {
        case api(Api)
        case view(View)
    }

    public enum Api: Equatable {
        case fetchResults
        case fetchResponse(SearchResponse)
    }

    @CasePathable
    public enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case rowTapped(ResponseType)
    }

    public enum CancelID: Hashable {
        case queryResults
    }

    public enum DebounceID: Hashable {
        case queryResults
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.networkClient) var networkClient

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
            .onChange(of: \.searchText) { oldValue, newValue in
                Reduce { state, action in
                    guard newValue != oldValue, !newValue.isEmpty else {
                        state.loadingState = newValue.isEmpty ? .idle : state.loadingState
                        return .none
                    }
                    state.loadingState = .loading
                    state.queryResults = []

                    return .send(.api(.fetchResults))
                        .debounce(id: DebounceID.queryResults, for: 0.5, scheduler: mainQueue)
                }
            }

        Reduce { state, action in
            switch action {
            case .api(.fetchResults):
                guard state.loadingState.completedPagination == false else {
                    return .none
                }

                // Derive page number from loading state.
                let page = if case let .paginated(currentPage, _) = state.loadingState {
                    currentPage + 1
                } else {
                    1
                }

                return .run { [query = state.searchText] send in
                    let response: SearchResponse = try await networkClient.request(SearchEndpoint.multi(query: query, page: page))
                    await send(.api(.fetchResponse(response)))
                }
                .cancellable(id: CancelID.queryResults, cancelInFlight: true)

            case let .api(.fetchResponse(response)):
                state.loadingState = .paginated(currentPage: response.page, totalPages: response.totalPages)
                // NOTE: This sorta breaks pagination since a page of results could contain only empty items.
                // NOTE: Nothing new would be added to the UI, so another `onAppear` wouldn't trigger.
                // NOTE: This should be handled when we parse people results properly.
                let cleanResults = response.results.filter { $0 != .empty }
                state.queryResults.append(contentsOf: cleanResults)
                return .none

            case .view(.binding):
                return .none

            case let .view(.rowTapped(item)):
                state.selectedFilm = SelectedFilm(film: item)
                return .none
            }
        }
    }
}
