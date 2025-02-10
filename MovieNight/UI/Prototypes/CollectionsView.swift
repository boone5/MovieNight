//
//  CollectionsView.swift
//  MovieNight
//
//  Created by Boone on 1/9/25.
//

import SwiftUI

struct CollectionsView: View {

    enum Collection: CaseIterable {
        case movie
        case tvShow
        case watchLater
        case custom

        var title: String {
            switch self {
            case .movie:
                "Movies"
            case .tvShow:
                "TV Shows"
            case .watchLater:
                "Want to watch"
            case .custom:
                "Custom"
            }
        }

        var symbol: String {
            switch self {
            case .movie:
                "movieclapper.fill"
            case .tvShow:
                "rectangle.portrait.on.rectangle.portrait.angled.fill"
            case .watchLater:
                "text.badge.checkmark"
            case .custom:
                ""
            }
        }
    }

    var collections: [Collection] = Collection.allCases

    var body: some View {
        VStack(alignment: .leading) {
            Text("Collections")
                .foregroundStyle(.white)
                .font(.system(size: 22, weight: .bold))

            ForEach(collections, id: \.self) { collection in
                VStack {
                    HStack {
                        Label {
                            Text(collection.title)
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .regular))
                        } icon: {
                            Image(systemName: collection.symbol)
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .regular))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                            .font(.system(size: 14, weight: .regular))
                    }
                    .padding(.vertical, 20)

                    Rectangle()
                        .foregroundStyle(.white.opacity(0.3))
                        .frame(height: 1)
                }
            }
        }
    }
}

#Preview {
    CollectionsView()
}
