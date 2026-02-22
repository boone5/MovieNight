//
//  AddToCollectionFeature.swift
//  App
//

import ComposableArchitecture
import Models
import Networking
import SwiftUI

@Reducer
public struct AddToCollectionFeature {
    public init() { }
    @ObservableState
    public struct State: Equatable {
        let media: MediaItem
        let customBackgroundColor: Color?

        var collectionModels: [CollectionModel] = []

        public init(media: MediaItem, customBackgroundColor: Color? = nil) {
            self.media = media
            self.customBackgroundColor = customBackgroundColor
        }
    }

    public enum Action: ViewAction, Equatable {
        case view(View)
    }

    @CasePathable
    public enum View: Equatable {
        case onTask
        case collectionToggled(CollectionModel)
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.movieProvider) var movieProvider

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onTask):
                state.collectionModels = buildCollectionModels()
                return .none

            case let .view(.collectionToggled(model)):
                let media = state.media
                if isFilmInCollection(model, media: media) {
                    try? movieProvider.removeFilmFromCollection(filmId: media.id, collectionId: model.id)
                } else {
                    saveToLibraryIfNecessary(media: media)
                    try? movieProvider.addFilmToCollection(filmId: media.id, collectionId: model.id)
                }
                state.collectionModels = buildCollectionModels()
                return .none
            }
        }
    }

    private func buildCollectionModels() -> [CollectionModel] {
        movieProvider.fetchAllCollections()
            .filter { $0.id != FilmCollection.recentlyWatchedID }
            .map { CollectionModel(from: $0) }
    }

    @discardableResult
    private func saveToLibraryIfNecessary(media: MediaItem) -> Film? {
        if let existingFilm = movieProvider.fetchFilm(media.id) {
            return existingFilm
        } else {
            return try? movieProvider.saveFilmToLibrary(.init(media))
        }
    }

    private func isFilmInCollection(_ collection: CollectionModel, media: MediaItem) -> Bool {
        collection.posterPaths.contains { $0 == media.posterPath }
    }
}
