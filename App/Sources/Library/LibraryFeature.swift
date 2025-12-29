//
//  LibraryFeature.swift
//  MovieNight
//
//  Created by Claude on 12/12/25.
//

import ComposableArchitecture
import Models
import SwiftUI
import UI

@Reducer
struct LibraryFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var selectedItem: MediaItem?

        public var navigationPath = NavigationPath()
    }

    enum Action: ViewAction, Equatable {
        case view(View)
    }

    @CasePathable
    enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case addCollectionButtonTapped
    }

    var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .view(.binding):
                return .none

            case .view(.addCollectionButtonTapped):
                // TODO: Add a collection
                return .none
            }
        }
    }
}
