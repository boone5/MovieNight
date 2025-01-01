//
//  ActionView.swift
//  MovieNight
//
//  Created by Boone on 12/31/24.
//

import SwiftUI

/*
 - allow deletion of the logs
 - allow "watched a ___ time" (i.e. "watched a 2nd time")
 - many updates could result in comments pushed to be bottom. keep in mind in future versions
 */

struct ActionView: View {
    enum ActionType {
        case rating(rating: Int16)
        case dateWatched(date: Date)
        case comment(comment: String)
    }

    let backgroundColor: UIColor
    let actionType: ActionType

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Text("Dec")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .bold))

                Text(" 31")
                    .foregroundStyle(.red)
                    .font(.system(size: 18, weight: .bold))

                Spacer()

                switch actionType {
                case .rating(let rating):
                    RatingView(rating: rating)

                case .dateWatched(let date):
                    WatchedView(date: date)

                case .comment(let comment):
                    CommentView(comment: comment)
                }
            }

            if case let .comment(comment) = actionType {
                Text(comment)
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .regular))
                    .padding(.top, 10)
            }
        }
        .padding(20)
        .background {
            Color(uiColor: .systemGray2).opacity(0.3)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }

    @ViewBuilder
    private func RatingView(rating: Int16) -> some View {
        HStack(spacing: 0) {
            Text("Rated")
                .foregroundStyle(.white)
                .font(.system(size: 14, weight: .regular))
                .padding(.trailing, 10)

            Text(String(rating))
                .foregroundStyle(.white)
                .font(.system(size: 18, weight: .bold))

            Image(systemName: "star.fill")
                .resizable()
                .foregroundStyle(Color(.gold))
                .frame(width: 13, height: 13)
                .padding(.leading, 5)
                .offset(y:-0.5)
        }
    }

    @ViewBuilder
    private func WatchedView(date: Date) -> some View {
        HStack(spacing: 0) {
            Image(systemName: "checkmark")
                .resizable()
                .foregroundStyle(.white)
                .frame(width: 15, height: 15)
                .padding(.trailing, 10)
                .fontWeight(.regular)

            Text("Watched")
                .foregroundStyle(.white)
                .font(.system(size: 14, weight: .regular))
        }
    }

    @ViewBuilder
    private func CommentView(comment: String) -> some View {
        HStack(spacing: 0) {
            Image(systemName: "text.bubble")
                .resizable()
                .foregroundStyle(.white)
                .frame(width: 15, height: 15)
                .padding(.trailing, 10)
                .fontWeight(.regular)

            Text("Comment")
                .foregroundStyle(.white)
                .font(.system(size: 14, weight: .regular))
        }
    }
}

#Preview {
    ActionView(backgroundColor: .black, actionType: .comment(comment: ""))
}
