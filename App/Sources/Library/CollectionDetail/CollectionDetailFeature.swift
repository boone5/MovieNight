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
        var collection: CollectionModel
        var films: [Film]
        var isEditing: Bool = false
        var isEditingTitle: Bool = false
        var originalTitle: String = ""

        @Presents var selectedFilm: SelectedFilm?
    }

    enum Action: ViewAction, Equatable {
        case view(View)
    }

    @CasePathable
    enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case tappedDeleteCollection
        case rowTapped(Film)
        case confirmRename
        case cancelRename
        case startRename
        case toggleReorderMode
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.movieProvider) var movieProvider

    var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .view(.binding):
                return .none

            case .view(.rowTapped(let film)):
                state.selectedFilm = SelectedFilm(film: film)
                return .none

            case .view(.startRename):
                state.originalTitle = state.collection.title
                state.isEditingTitle = true
                return .none

            case .view(.confirmRename):
                let collectionID = state.collection.id
                let newTitle = state.collection.title
                state.isEditingTitle = false
                return .run { _ in
                    try movieProvider.renameCollection(collectionID, to: newTitle)
                }

            case .view(.cancelRename):
                state.collection.title = state.originalTitle
                state.isEditingTitle = false
                return .none

            case .view(.tappedDeleteCollection):
                let collectionID = state.collection.id
                return .run { _ in
                    try movieProvider.deleteCollection(collectionID)
                    await dismiss()
                }

            case .view(.toggleReorderMode):
                state.isEditing.toggle()
                return .none
            }
        }
    }
}
