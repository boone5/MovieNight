//
//  CollectionDetailFeature.swift
//  MovieNight
//
//  Created by Claude on 12/17/25.
//

import ComposableArchitecture
import Foundation
import Models
import Networking
import UI

@Reducer
struct CollectionDetailFeature {
    @ObservableState
    struct State: Equatable {
        let collectionID: UUID
        let title: String
        let films: [Film]

        @Presents var selectedFilm: SelectedFilm?
    }

    enum Action: ViewAction, Equatable {
        case view(View)
    }

    @CasePathable
    enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case tappedRenameCollection
        case tappedDeleteCollection
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.movieProvider) var movieProvider

    var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .view(.binding):
                return .none

            case .view(.tappedRenameCollection):
                // TODO: Implement rename
                return .none

            case .view(.tappedDeleteCollection):
                let collectionID = state.collectionID
                return .run { _ in
                    try movieProvider.deleteCollection(collectionID)
                    await dismiss()
                }
            }
        }
    }
}
