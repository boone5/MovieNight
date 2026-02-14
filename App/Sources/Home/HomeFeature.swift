//
//  HomeFeature.swift
//  App
//

import ComposableArchitecture
import Models
import Networking

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var nowPlaying: [MediaItem] = []
        var upcoming: [MediaItem] = []
        var trendingMovies: [MediaItem] = []
        var trendingTVShows: [MediaItem] = []
        @Presents var selectedItem: MediaItem?
    }

    enum Action: ViewAction, Equatable {
        case api(Api)
        case view(View)
    }

    enum Api: Equatable {
        case nowPlayingResponse(Result<MoviesResponse, APIError>)
        case upcomingResponse(Result<MoviesResponse, APIError>)
        case trendingMoviesResponse(Result<MoviesResponse, APIError>)
        case trendingTVShowsResponse(Result<TrendingTVShowsResponse, APIError>)
    }

    @CasePathable
    enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onTask
    }

    @Dependency(\.networkClient) var networkClient

    var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .view(.onTask):
                return .merge(
                    .run { send in
                        await send(.api(.nowPlayingResponse(Result { try await networkClient.fetchNowPlaying() }.mapError { $0 as? APIError ?? .unknownError($0) })))
                    },
                    .run { send in
                        await send(.api(.upcomingResponse(Result { try await networkClient.fetchUpcoming(5, 5) }.mapError { $0 as? APIError ?? .unknownError($0) })))
                    },
                    .run { send in
                        await send(.api(.trendingMoviesResponse(Result { try await networkClient.fetchTrendingMovies() }.mapError { $0 as? APIError ?? .unknownError($0) })))
                    },
                    .run { send in
                        await send(.api(.trendingTVShowsResponse(Result { try await networkClient.fetchTrendingTVShows() }.mapError { $0 as? APIError ?? .unknownError($0) })))
                    },
                )

            case let .api(.nowPlayingResponse(.success(response))):
                state.nowPlaying = response.results.map { MediaItem(from: .movie($0) )}
                return .none

            case .api(.nowPlayingResponse(.failure)):
                return .none

            case let .api(.upcomingResponse(.success(response))):
                state.upcoming = response.results.map { MediaItem(from: .movie($0)) }
                return .none

            case .api(.upcomingResponse(.failure)):
                return .none

            case let .api(.trendingMoviesResponse(.success(response))):
                let movies = response.results.map { MediaItem(from: .movie($0) )}
                state.trendingMovies = movies
                return .none

            case .api(.trendingMoviesResponse(.failure)):
                return .none

            case let .api(.trendingTVShowsResponse(.success(response))):
                let shows = response.results.map(MediaItem.init)
                state.trendingTVShows = shows
                return .none

            case .api(.trendingTVShowsResponse(.failure)):
                return .none

            case .view(.binding):
                return .none
            }
        }
    }
}
