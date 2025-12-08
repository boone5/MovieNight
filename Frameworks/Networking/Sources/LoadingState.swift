//
//  LoadingState.swift
//  MovieNight
//
//  Created by Boone on 2/4/24.
//

import CasePaths

@CasePathable
public enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case paginated(currentPage: Int, totalPages: Int)

    public var isLoading: Bool {
        \.loading ~= self
    }

    public var completedPagination: Bool {
        guard case .paginated(let currentPage, let totalPages) = self else {
            return false
        }
        return currentPage == totalPages
    }
}
