//
//  AppFeature.swift
//  App
//
//  Created by Ayren King on 12/5/25.
//

import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        init(selectedTab: AppTab = .home) {
            self.selectedTab = selectedTab
        }

        var selectedTab: AppTab
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
    }
}
