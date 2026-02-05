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
        var films: [MediaItem]
        var title: String

        var isReordering: Bool = false
        var isEditingTitle: Bool = false
        var originalTitle: String = ""

        @Presents var selectedFilm: MediaItem?

        init(collection: CollectionModel, films: [MediaItem]) {
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
        case rowTapped(MediaItem)
        case finishRename
        case cancelRename
        case startRename
        case toggleReorderMode
        case moveFilms(IndexSet, Int)
        case moveFilmsSuccess(IndexSet, Int)
        case deleteFilms(IndexSet)
        case deleteFilmsSuccess(IndexSet)
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
                state.selectedFilm = film
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
                } catch: { error, send in
                    print(error.localizedDescription)
                    // TODO: Add error handling for renameCollection failure (PR #13)
                    // - Catch errors and revert state.title and state.collection.title to originalTitle
                    // - Display user-facing alert with error message
                    // await send(.displayErrorToast(.renameError))
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
                } catch: { error, send in
                    // TODO: Add error handling for deleteCollection failure (PR #13)
                    // - Catch errors and display user-facing alert
                    // - Do not dismiss if deletion fails
                    // await send(.displayErrorToast(.deleteError))
                }

            case .view(.toggleReorderMode):
                state.isReordering.toggle()
                return .none

            case .view(.moveFilms(let source, let destination)):
                let collectionId = state.collection.id
                var reorderedFilms = state.films
                reorderedFilms.move(fromOffsets: source, toOffset: destination)
                let filmIds = reorderedFilms.map(\.id)
                return .run { send in
                    try movieProvider.updateFilmOrder(filmIds: filmIds, inCollection: collectionId)
                    await send(.view(.moveFilmsSuccess(source, destination)))
                } catch: { error, send in
                    print(error.localizedDescription)
                    // TODO: Add error handling (PR #13)
                }

            case .view(.moveFilmsSuccess(let source, let destination)):
                state.films.move(fromOffsets: source, toOffset: destination)
                return .none

            case .view(.deleteFilms(let offsets)):
                let filmsToDelete = offsets.map { state.films[$0] }
                let collectionId = state.collection.id
                return .run { [collection = state.collection] send in
                    if collection.id == FilmCollection.recentlyWatchedID {
                        // remove from library
                        for film in filmsToDelete {
                            try movieProvider.deleteFilm(film.id)
                        }
                    } else {
                        // remove from collection
                        for film in filmsToDelete {
                            try movieProvider.removeFilmFromCollection(filmId: film.id, collectionId: collectionId)
                        }
                    }
                    await send(.view(.deleteFilmsSuccess(offsets)))
                } catch: { error, send in
                    print(error.localizedDescription)
                    // TODO: Add error handling (PR #13)
                }

            case .view(.deleteFilmsSuccess(let offsets)):
                state.films.remove(atOffsets: offsets)
                state.collection.filmCount = state.films.count
                return .none
            }
        }
    }
}
