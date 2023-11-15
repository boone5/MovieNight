//
//  CDMovieResult+Extensions.swift
//  MovieNight
//
//  Created by Boone on 10/30/23.
//

import Foundation

extension CDTitleText {
    var text: String {
        get {
            text_ ?? ""
        }
        set {
            text_ = newValue
        }
    }
}

extension CDReleaseYear {
    var year: Int16 {
        get {
            Int16(year_)
        }
        set {
            year_ = newValue
        }
    }
}
