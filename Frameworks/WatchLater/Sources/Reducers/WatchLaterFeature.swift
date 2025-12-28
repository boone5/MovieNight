//
//  WatchLaterFeature.swift
//  Logger
//
//  Created by Ayren King on 12/13/25.
//

import ComposableArchitecture
import Models
import SwiftUI
import UI

@Reducer
public struct WatchLaterFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public init() {}

        var navigationPath = NavigationPath()
        var searchText: String = ""
        var isSearchFieldFocused: Bool = false

        @Presents var selectedFilm: MediaItem?
    }

    public enum Action: ViewAction, Equatable {
        case view(View)
    }

    @CasePathable
    public enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case clearSearchFieldButtonTapped
        case readyToWatchFilmButtonTapped(MediaItem?)
        case spinWheelButtonTapped
    }

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            case .view(.binding):
                return .none

            case .view(.clearSearchFieldButtonTapped):
                state.searchText = ""
                state.isSearchFieldFocused = false
                return .none

            case .view(.readyToWatchFilmButtonTapped(let film)):
                guard let film else { return .none }
                state.selectedFilm = film
                return .none

            case .view(.spinWheelButtonTapped):
                state.navigationPath.append(WatchLaterPath.wheel)
                return .none
            }
        }
    }
}

enum WatchLaterPath: Hashable {
    case wheel
}
