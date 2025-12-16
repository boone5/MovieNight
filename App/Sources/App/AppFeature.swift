//
//  AppFeature.swift
//  App
//
//  Created by Ayren King on 12/5/25.
//

import ComposableArchitecture
import Search
import WatchLater

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        init(selectedTab: AppTab = .home) {
            self.selectedTab = selectedTab
        }

        var selectedTab: AppTab

        var library: LibraryFeature.State = .init()
        var search: SearchFeature.State = .init()
        var watchLater: WatchLaterFeature.State = .init()
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case library(LibraryFeature.Action)
        case search(SearchFeature.Action)
        case watchLater(WatchLaterFeature.Action)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.library, action: \.library, child: LibraryFeature.init)
        Scope(state: \.search, action: \.search, child: SearchFeature.init)
        Scope(state: \.watchLater, action: \.watchLater, child: WatchLaterFeature.init)

        Reduce { state, action in
            switch action {
            case .binding: return .none

            case .library: return .none

            case .search: return .none

            case .watchLater: return .none
            }
        }
    }
}
