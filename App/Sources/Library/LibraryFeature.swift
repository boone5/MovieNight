//
//  LibraryFeature.swift
//  MovieNight
//
//  Created by Claude on 12/12/25.
//

import ComposableArchitecture
import Foundation
import Models
import SwiftUI
import UI

extension LibraryFeature.Path.State: Equatable { }
extension LibraryFeature.Path.Action: Equatable { }

@Reducer
struct LibraryFeature {
    @Reducer
    enum Path {
        case collectionDetail(CollectionDetailFeature)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()

        @Presents var selectedFilm: SelectedFilm?
        @Presents var addCollection: AddCollectionFeature.State?
    }

    enum Action: ViewAction, Equatable {
        case path(StackActionOf<Path>)
        case view(View)
        case addCollection(PresentationAction<AddCollectionFeature.Action>)
    }

    @CasePathable
    enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case tappedAddCollectionButton
        case tappedCollection(FilmCollection)
    }

    var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .view(.binding), .addCollection, .path:
                return .none

            case .view(.tappedAddCollectionButton):
                state.addCollection = AddCollectionFeature.State()
                return .none

            case let .view(.tappedCollection(collection)):
                let films = collection.films?.array as? [Film] ?? []
                state.path.append(.collectionDetail(CollectionDetailFeature.State(
                    collectionID: collection.id ?? UUID(),
                    title: collection.title ?? "",
                    films: films
                )))
                return .none
            }
        }
        .ifLet(\.$addCollection, action: \.addCollection) {
            AddCollectionFeature()
        }
        .forEach(\.path, action: \.path)
    }
}
