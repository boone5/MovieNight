//
//  TVShowDetailViewModel.swift
//  MovieNight
//
//  Created by Boone on 3/24/24.
//

import Foundation

class TVShowDetailViewModel: ObservableObject {
    public var tvShow: TVShowResponse

    init(tvShow: TVShowResponse) {
        self.tvShow = tvShow
    }
}
