//
//  ActionView3.swift
//  MovieNight
//
//  Created by Boone on 1/2/25.
//

import SwiftUI

struct FeedbackButtons: View {
    @Binding public var isLiked: Bool
    @Binding public var isLoved: Bool
    @Binding public var isDisliked: Bool

    public let averageColor: UIColor

    public var didAddActivity: ((Bool, Bool, Bool) -> ())? = nil

    var body: some View {
        HStack(spacing: 20) {
            ButtonView(type: .like(enabled: isLiked), averageColor: averageColor) {
                isLiked.toggle()
                isDisliked = false
                isLoved = false
                didAddActivity?(isLiked, isLoved, isDisliked)
            }

            ButtonView(type: .dislike(enabled: isDisliked), averageColor: averageColor) {
                isLiked = false
                isDisliked.toggle()
                isLoved = false
                didAddActivity?(isLiked, isLoved, isDisliked)
            }

            ButtonView(type: .love(enabled: isLoved), averageColor: averageColor) {
                isLiked = false
                isDisliked = false
                isLoved.toggle()
                didAddActivity?(isLiked, isLoved, isDisliked)
            }
        }
    }

    fileprivate struct ButtonView: View {
        let type: Feedback
        let averageColor: UIColor
        let action: () -> Void

        var isEnabled: Bool {
            switch type {
            case .like(let enabled):
                enabled
            case .dislike(let enabled):
                enabled
            case .love(let enabled):
                enabled
            }
        }

        var body: some View {
            Button {
                action()
            } label: {
                Image(systemName: type.imageName)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(type.color)
                    .padding(20)
                    .background {
                        Group {
                            if isEnabled {
                                Color(type.color).opacity(0.2)
                            } else {
                                Color(uiColor: averageColor).opacity(0.4)

                            }
                        }
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                    }
            }
        }
    }
}

enum Feedback {
    case like(enabled: Bool)
    case dislike(enabled: Bool)
    case love(enabled: Bool)

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
        case .like(false), .dislike(false), .love(false):
            .white
        }
    }
}

#Preview {
//    ActionView3()
}
