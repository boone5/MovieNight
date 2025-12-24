//
//  Feedback+UI.swift
//  Models
//
//  Created by Ayren King on 12/23/25.
//

import Models
import SwiftUI

extension Feedback {
    public var selectedImageName: String {
        switch self {
        case .like: "hand.thumbsup.fill"
        case .dislike: "hand.thumbsdown.fill"
        case .love: "heart.fill"
        }
    }

    public var unSelectedImageName: String {
        switch self {
        case .like: "hand.thumbsup"
        case .dislike: "hand.thumbsdown"
        case .love: "heart"
        }
    }

    public var color: Color {
        switch self {
        case .like: .green
        case .dislike: Color(.burntOrange)
        case .love: .red
        }
    }
}
