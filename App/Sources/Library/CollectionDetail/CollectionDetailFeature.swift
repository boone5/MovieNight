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
        let collection: FilmCollection
        var films: [Film]
        var isEditing: Bool = false

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
        case rowTapped(Film)
        case actionTapped(CollectionType.Action)
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

            case .view(.actionTapped(let action)):
                switch action {
                case .addFilm:
                    // TODO: Open Search Sheet
                    print("addFilm tapped")
                case .reorder:
                    state.isEditing.toggle()

                case .rename:
                    // TODO: Rename Collection
                    print("rename tapped")
                }
                return .none

            case .view(.tappedRenameCollection):
                // TODO: Implement rename
                return .none

            case .view(.tappedDeleteCollection):
                guard let collectionID = state.collection.id else { return .none }
                return .run { _ in
                    try movieProvider.deleteCollection(collectionID)
                    await dismiss()
                }
            }
        }
    }
}
