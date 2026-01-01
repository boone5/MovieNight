//
//  MediaItem+Color.swift
//  Frameworks
//
//  Created by Ayren King on 12/28/25.
//

import Models
import SwiftUI
import UI

extension MediaType {
    var color: Color {
        switch self {
        case .movie: Color.goldPopcorn
        case .tv: Color.popRed
        case .person: Color.card
        }
    }
}
