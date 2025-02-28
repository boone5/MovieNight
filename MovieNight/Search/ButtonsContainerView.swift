//
//  ActionView3.swift
//  MovieNight
//
//  Created by Boone on 1/2/25.
//

import SwiftUI

struct ButtonsContainerView: View {
    @Binding public var isLiked: Bool
    @Binding public var isLoved: Bool
    @Binding public var isDisliked: Bool

    public var didAddActivity: ((Bool, Bool, Bool) -> ())? = nil
    public var comment: String? = nil

    var body: some View {
        HStack(spacing: 15) {
            ButtonView(type: .like(enabled: isLiked))
                .onTapGesture {
                    isLiked.toggle()
                    isDisliked = false
                    isLoved = false
                    didAddActivity?(isLiked, isLoved, isDisliked)
                }

            ButtonView(type: .dislike(enabled: isDisliked))
                .onTapGesture {
                    isLiked = false
                    isDisliked.toggle()
                    isLoved = false
                    didAddActivity?(isLiked, isLoved, isDisliked)
                }

            ButtonView(type: .love(enabled: isLoved))
                .onTapGesture {
                    isLiked = false
                    isDisliked = false
                    isLoved.toggle()
                    didAddActivity?(isLiked, isLoved, isDisliked)
                }

            ButtonView(type: .comment)
        }
    }
}

enum Feedback {
    case like(enabled: Bool)
    case dislike(enabled: Bool)
    case love(enabled: Bool)
    case comment

    var imageName: String {
        switch self {
        case .like(true):
            "hand.thumbsup.fill"
        case .like(false):
            "hand.thumbsup"
        case .dislike(true):
            "hand.thumbsdown.fill"
        case .dislike(false):
            "hand.thumbsdown"
        case .love(true):
            "heart.fill"
        case .love(false):
            "heart"
        case .comment:
            "text.bubble"
        }
    }

    var color: Color {
        switch self {
        case .like(true):
            .green
        case .dislike(true):
            Color(.burntOrange)
        case .love(true):
            .red
        case .like(false), .dislike(false), .love(false), .comment:
            .white
        }
    }
}

fileprivate struct ButtonView: View {
    let type: Feedback

    var body: some View {
        Image(systemName: type.imageName)
            .font(.system(size: 24, weight: .medium))
            .foregroundStyle(type.color)
            .padding(20)
            .background {
                Color(type.color).opacity(0.2)
                    .clipShape(Circle())
            }
    }
}

#Preview {
//    ActionView3()
}
