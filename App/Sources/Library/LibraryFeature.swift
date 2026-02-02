//
//  LibraryFeature.swift
//  MovieNight
//
//  Created by Claude on 12/12/25.
//

import ComposableArchitecture
import Foundation
import Models
import Networking
import SwiftUI
import UI

extension LibraryFeature.Path.State: Equatable { }
extension LibraryFeature.Path.Action: Equatable { }

@Reducer
struct LibraryFeature {
    @Dependency(\.movieProvider) var movieProvider

    @Reducer
    enum Path {
        case collectionDetail(CollectionDetailFeature)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var collections: [CollectionModel] = []
        var recentlyWatchedCount: Int = 0

        @Presents var selectedItem: MediaItem?
        @Presents var addCollection: CreateCollectionFeature.State?

        var shouldShowContent: Bool {
            recentlyWatchedCount >= 1 || collections.count >= 1
        }
    }

    enum Action: ViewAction, Equatable {
        case path(StackActionOf<Path>)
        case view(View)
        case addCollection(PresentationAction<CreateCollectionFeature.Action>)
    }

    @CasePathable
    enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case collectionsUpdated([FilmCollection])
        case recentlyWatchedCountChanged(Int)
        case tappedAddCollectionButton
        case tappedCollection(CollectionModel)
    }

    var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case let .view(.collectionsUpdated(collections)):
                state.collections = collections.map { CollectionModel(from: $0) }
                return .none

            case let .view(.recentlyWatchedCountChanged(count)):
                state.recentlyWatchedCount = count
                return .none

            case .view(.tappedAddCollectionButton):
                state.addCollection = CreateCollectionFeature.State()
                return .none

            case let .view(.tappedCollection(collectionModel)):
                let films = movieProvider.fetchCollection(collectionModel.id)?.films?.array as? [Film] ?? []
                state.path.append(.collectionDetail(CollectionDetailFeature.State(
                    collection: collectionModel,
                    films: films
                )))
                return .none

            case let .path(.element(id, action: .collectionDetail(.view(.finishRename)))):
                guard case let .collectionDetail(detailState) = state.path[id: id] else {
                    return .none
                }
                if let index = state.collections.firstIndex(where: { $0.id == detailState.collection.id }) {
                    state.collections[index].title = detailState.collection.title
                }
                return .none

            case .view(.binding), .addCollection, .path:
                return .none
            }
        }
        .ifLet(\.$addCollection, action: \.addCollection) {
            CreateCollectionFeature()
        }
        .forEach(\.path, action: \.path)
    }
}
