//
//  ResultRow.swift
//  Frameworks
//
//  Created by Ayren King on 12/28/25.
//

import Models
import SwiftUI
import UI

struct ResultRow: View {
    let media: MediaItem
    let namespace: Namespace.ID

    let action: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            ThumbnailView(
                media: media,
                size: .init(width: 80, height: 120),
                transitionConfig: .init(namespace: namespace, source: media)
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(media.title)
                    .font(.montserrat(size: 16, weight: .semibold))
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)

                switch media.mediaType {
                case .movie, .tv:
                    if let overview = media.overview {
                        Text(overview)
                            .font(.openSans(size: 12, weight: .regular))
                            .lineLimit(2)
                            .clipped()
                            .multilineTextAlignment(.leading)
                    }
                case .person:
                    let person = media.person
                    HStack(spacing: 2) {
                        if let knownForDepartment = person?.knownForDepartment {
                            Text(knownForDepartment)
                                .font(.openSans(size: 12, weight: .semibold))

                            if person?.knownFor.isEmpty == false {
                                Text("•")
                                    .font(.openSans(size: 12, weight: .semibold))
                            }
                        }

                        if let knownFor = person?.knownFor.first {
                            Text(knownFor.title)
                                .font(.openSans(size: 12, weight: .regular))
                        }
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .truncationMode(.tail)
                }

                Text(media.mediaType.title)
                    .font(.openSans(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .clipShape(.capsule)
                    .frame(width: 50)
                    .background {
                        Capsule()
                            .fill(media.mediaType.color.opacity(0.85))
                            .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                    }

            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring()) {
                action()
            }
        }
        .padding(.vertical, 5)
    }
}
