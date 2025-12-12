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
        var headerOpacity: Double = 1.0

        @Presents var selectedFilm: SelectedFilm?
    }

    enum Action: ViewAction, Equatable {
        case view(View)
    }

    @CasePathable
    enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case headerScrolled(minY: CGFloat)
        case searchButtonTapped
        case addCollectionButtonTapped
    }

    var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .view(.binding):
                return .none

            case let .view(.headerScrolled(minY)):
                let fadeThreshold = 50.0
                state.headerOpacity = max(0, min(1, (minY + fadeThreshold) / fadeThreshold))
                return .none

            case .view(.searchButtonTapped):
                // TODO: Search Library
                return .none

            case .view(.addCollectionButtonTapped):
                // TODO: Add a collection
                return .none
            }
        }
    }
}
