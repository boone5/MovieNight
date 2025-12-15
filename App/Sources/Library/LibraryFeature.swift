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
        @Presents var selectedFilm: SelectedFilm?
        @Presents var addCollection: AddCollectionFeature.State?

        public var navigationPath = NavigationPath()
    }

    enum Action: ViewAction, Equatable {
        case view(View)
        case addCollection(PresentationAction<AddCollectionFeature.Action>)
    }

    @CasePathable
    enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case tappedAddCollectionButton
    }

    var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .view(.binding), .addCollection:
                return .none

            case .view(.tappedAddCollectionButton):
                state.addCollection = AddCollectionFeature.State()
                return .none
            }
        }
        .ifLet(\.$addCollection, action: \.addCollection) {
            AddCollectionFeature()
        }
    }
}
