//
//  WatchLaterFeature.swift
//  Logger
//
//  Created by Ayren King on 12/13/25.
//

import ComposableArchitecture
import FortuneWheel
import Models
import SwiftUI
import UI

@Reducer
public struct WatchLaterFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public init() {}

        @Shared(.appStorage("wheelSpinCount")) var wheelSpinCount: Int = 0

        var navigationPath = NavigationPath()

        var selectedCollection: CollectionModel?
        var selectedCollectionMediaItems: [MediaItem]?
        var chosenWheelIndex: [MediaItem].Index?
        var isPresentingCollectionPicker = false

        var canUpdateCollection: Bool = true

        var selectedCollectionHasItems: Bool {
            !(selectedCollectionMediaItems?.isEmpty ?? true)
        }

        @Presents var selectedItem: MediaItem?
    }

    public enum Action: ViewAction, Equatable {
        case view(View)
    }

    @CasePathable
    public enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case readyToWatchFilmButtonTapped(MediaItem?)
        case selectCollectionPickerButtonTapped
        case collectionPickerValueUpdated(FilmCollection?)
        case wheelStateDidChange(SpinState)
        case onMediaModalDismiss
    }

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            case .view(.binding):
                return .none

            case .view(.readyToWatchFilmButtonTapped(let item)):
                guard let item else { return .none }
                state.selectedItem = item
                return .none

            case .view(.selectCollectionPickerButtonTapped):
                state.isPresentingCollectionPicker = true
                return .none

            case .view(.collectionPickerValueUpdated(let collection)):
                state.selectedCollection = collection.flatMap(CollectionModel.init)
                state.selectedCollectionMediaItems = collection?.mediaItems
                state.isPresentingCollectionPicker = false
                return .none

            case .view(.wheelStateDidChange(let spinState)):
                switch spinState {
                case .idle:
                    return .none
                case .spinning:
                    state.chosenWheelIndex = nil
                    state.canUpdateCollection = false
                case .finished(let index):
                    state.chosenWheelIndex = index
                    state.$wheelSpinCount.withLock { $0 += 1 }

                }
                return .none

            case .view(.onMediaModalDismiss):
                state.chosenWheelIndex = nil
                state.canUpdateCollection = true
                return .none
            }
        }
    }
}
