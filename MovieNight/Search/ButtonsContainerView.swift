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

    public let averageColor: UIColor

    public var didAddActivity: ((Bool, Bool, Bool) -> ())? = nil
    public var didTapAddComment: (() -> Void)? = nil
    public var comment: String? = nil

    var body: some View {
        HStack(spacing: 15) {
            ButtonView(type: .like(enabled: isLiked)) {
                isLiked.toggle()
                isDisliked = false
                isLoved = false
                didAddActivity?(isLiked, isLoved, isDisliked)
            }

            ButtonView(type: .dislike(enabled: isDisliked)) {
                isLiked = false
                isDisliked.toggle()
                isLoved = false
                didAddActivity?(isLiked, isLoved, isDisliked)
            }

            ButtonView(type: .love(enabled: isLoved)) {
                isLiked = false
                isDisliked = false
                isLoved.toggle()
                didAddActivity?(isLiked, isLoved, isDisliked)
            }

            ButtonView(type: .comment) {
                didTapAddComment?()
            }
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity)
        .background {
            Color(uiColor: averageColor).opacity(0.3)
                .clipShape(RoundedRectangle(cornerRadius: 15))
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
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: type.imageName)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(type.color)
                .padding(20)
                .background {
                    Color(type.color).opacity(0.2)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                }
        }
    }
}

#Preview {
//    ActionView3()
}
