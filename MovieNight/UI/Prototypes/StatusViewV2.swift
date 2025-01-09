//
//  StatusViewV2.swift
//  MovieNight
//
//  Created by Boone on 1/2/25.
//

import SwiftUI

struct StatusViewV2: View {
    public enum State {
        case watched
        case wantToWatch
        case unwatched
    }

    public var status: State = .watched

    var body: some View {
        HStack(spacing: 10) {
            switch status {
            case .watched:
                StatusButton(type: .watched)
                StatusButton(type: .share)

            case .wantToWatch:
                StatusButton(type: .unwatched)
                StatusButton(type: .wantToWatchSelected)

            case .unwatched:
                StatusButton(type: .unwatched)
                StatusButton(type: .wantToWatch)
            }
        }
    }
}

private struct StatusButton: View {
    enum `Type` {
        case watched
        case wantToWatch
        case wantToWatchSelected
        case unwatched
        case share
    }

    public var type: Type

    var body: some View {
        switch type {
        case .watched:
            HStack(spacing: 10) {
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)

                Text("Watched")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(width: 150, height: 25)
            .padding(10)
            .background {
                Color(uiColor: .systemGray2)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }

        case .wantToWatch:
            HStack(spacing: 10) {
                Image(systemName: "text.badge.plus")
                    .foregroundStyle(.white)

                Text("Want to watch")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(width: 150, height: 25)
            .padding(10)
            .background {
                Color(uiColor: .systemGray2)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }

        case .wantToWatchSelected:
            HStack(spacing: 10) {
                Image(systemName: "text.badge.checkmark")
                    .foregroundStyle(.white)

                Text("Want to watch")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(width: 150, height: 25)
            .padding(10)
            .background {
                Color(uiColor: .systemGray2)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }

        case .unwatched:
            HStack(spacing: 10) {
                Image(systemName: "plus")
                    .foregroundStyle(.white)

                Text("Already watched")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(width: 150, height: 25)
            .padding(10)
            .background {
                Color(uiColor: .systemGray2)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }

        case .share:
            HStack(spacing: 10) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.white)

                Text("Share")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(width: 150, height: 25)
            .padding(10)
            .background {
                Color(uiColor: .systemGray2).opacity(0.3)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
    }
}

#Preview {
    StatusViewV2()
}
