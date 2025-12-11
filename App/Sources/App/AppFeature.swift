//
//  AppFeature.swift
//  App
//
//  Created by Ayren King on 12/5/25.
//

import ComposableArchitecture
import Search

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        init(selectedTab: AppTab = .home) {
            self.selectedTab = selectedTab
        }

        var selectedTab: AppTab

        var search: SearchFeature.State = .init()
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case search(SearchFeature.Action)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.search, action: \.search, child: SearchFeature.init)

        Reduce { state, action in
            switch action {
            case .binding: return .none

            case .search: return .none
            }
        }
    }
}
