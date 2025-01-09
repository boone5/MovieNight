//
//  ActionView3.swift
//  MovieNight
//
//  Created by Boone on 1/2/25.
//

import SwiftUI

struct ActionView3: View {
    @Binding public var isLiked: Bool
    @Binding public var isLoved: Bool
    @Binding public var isDisliked: Bool

    public var didAddActivity: ((Bool, Bool, Bool) -> ())? = nil
    public var comment: String? = nil

    var body: some View {
        HStack(spacing: 15) {
            ThumbsUpButton

            ThumbsDownButton

            LoveButton

            Image(systemName: "text.bubble")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .padding(20)
                .background {
                    Color(uiColor: .systemGray2).opacity(0.3)
                        .clipShape(Circle())
                }
        }
    }

    private var ThumbsUpButton: some View {
        Group {
            if isLiked {
                Image(systemName: "hand.thumbsup.fill")
                    .foregroundStyle(.green)

            } else {
                Image(systemName: "hand.thumbsup")
                    .foregroundStyle(.white)
            }
        }
        .font(.system(size: 24, weight: .medium))
        .padding(20)
        .background {
            Color(uiColor: .systemGray2).opacity(0.3)
                .clipShape(Circle())
        }
        .onTapGesture {
            isLiked.toggle()
            isDisliked = false
            isLoved = false
            didAddActivity?(isLiked, isLoved, isDisliked)
        }
    }

    private var ThumbsDownButton: some View {
        Group {
            if isDisliked {
                Image(systemName: "hand.thumbsdown.fill")
                    .foregroundStyle(Color(.burntOrange))
            } else {
                Image(systemName: "hand.thumbsdown")
                    .foregroundStyle(.white)
            }
        }
        .font(.system(size: 24, weight: .medium))
        .padding(20)
        .background {
            Color(uiColor: .systemGray2).opacity(0.3)
                .clipShape(Circle())
        }
        .onTapGesture {
            isDisliked.toggle()
            isLiked = false
            isLoved = false
            didAddActivity?(isLiked, isLoved, isDisliked)
        }
    }

    private var LoveButton: some View {
        Group {
            if isLoved {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)

            } else {
                Image(systemName: "heart")
                    .foregroundStyle(.white)
            }
        }
        .font(.system(size: 24, weight: .medium))
        .padding(20)
        .background {
            Color(uiColor: .systemGray2).opacity(0.3)
                .clipShape(Circle())
        }
        .onTapGesture {
            isLoved.toggle()
            isDisliked = false
            isLiked = false
            didAddActivity?(isLiked, isLoved, isDisliked)
        }
    }
}

#Preview {
//    ActionView3()
}
