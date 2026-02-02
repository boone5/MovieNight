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
        var title: String

        var isReordering: Bool = false
        var isEditingTitle: Bool = false
        var originalTitle: String = ""

        @Presents var selectedFilm: MediaItem?

        init(collection: CollectionModel, films: [Film]) {
            self.collection = collection
            self.title = collection.title
            self.films = films
        }
    }

    enum Action: ViewAction, Equatable {
        case view(View)
    }

    @CasePathable
    enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case tappedDeleteCollection
        case rowTapped(Film)
        case finishRename
        case cancelRename
        case startRename
        case toggleReorderMode
        case moveFilms(IndexSet, Int)
        case deleteFilms(IndexSet)
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
                state.selectedFilm = MediaItem(from: film)
                return .none

            case .view(.startRename):
                state.originalTitle = state.collection.title
                state.isEditingTitle = true
                return .none

            case .view(.finishRename):
                let collectionID = state.collection.id
                let newTitle = state.title

                state.isEditingTitle = false
                state.collection.title = state.title

                return .run { send in
                    try movieProvider.renameCollection(collectionID, to: newTitle)
                }

            case .view(.cancelRename):
                state.title = state.originalTitle
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
                state.isReordering.toggle()
                return .none

            case .view(.moveFilms(let source, let destination)):
                state.films.move(fromOffsets: source, toOffset: destination)
                return .none

            case .view(.deleteFilms(let offsets)):
                let filmsToDelete = offsets.map { state.films[$0] }
                let collectionId = state.collection.id
                state.films.remove(atOffsets: offsets)
                state.collection.filmCount = state.films.count
                return .run { _ in
                    for film in filmsToDelete {
                        try movieProvider.removeFilmFromCollection(filmId: film.id, collectionId: collectionId)
                    }
                }
            }
        }
    }
}
