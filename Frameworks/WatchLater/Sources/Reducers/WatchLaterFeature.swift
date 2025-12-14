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

        @Presents var selectedFilm: SelectedFilm?
    }

    public enum Action: ViewAction, Equatable {
        case view(View)
    }

    @CasePathable
    public enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case readyToWatchFilmButtonTapped(Film?)
        case spinWheelButtonTapped
    }

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            case .view(.binding):
                return .none

            case .view(.readyToWatchFilmButtonTapped(let film)):
                guard let film else { return .none }
                state.selectedFilm = SelectedFilm(film: film)
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
