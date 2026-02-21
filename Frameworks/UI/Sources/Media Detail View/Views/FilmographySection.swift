//
//  FilmographySection.swift
//  Frameworks
//
//  Created by Ayren King on 12/28/25.
//

import Models
import SwiftUI

struct FilmographySection: View {
    enum Credit: Identifiable {
        case cast(AdditionalDetailsPerson.PersonCastCredit)
        case crew(AdditionalDetailsPerson.PersonCrewCredit)

        var id: String {
            switch self {
            case .cast(let c): return c.id
            case .crew(let c): return c.id
            }
        }

        var media: MediaResult {
            switch self {
            case .cast(let c): return c.media
            case .crew(let c): return c.media
            }
        }

        var subtitle: String? {
            switch self {
            case .cast(let c): return c.character
            case .crew(let c): return c.job
            }
        }
    }

    let title: String
    let credits: [Credit]
    let averageColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.montserrat(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(credits) { credit in
                        FilmographyItem(credit: credit)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .background(averageColor.opacity(0.4))
        .cornerRadius(12)
    }
}

private struct FilmographyItem: View {
    let credit: FilmographySection.Credit
    @Namespace private var namespace

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ThumbnailView(
                media: .init(from: credit.media),
                size: .init(width: 120, height: 180),
                transitionConfig: .init(namespace: namespace, source: .init(from: credit.media))
            )
            .clipShape(.rect(cornerRadius: 8))

            Text(credit.media.title)
                .font(.openSans(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)

            if let sub = credit.subtitle, sub.isEmpty == false {
                Text(sub)
                    .font(.openSans(size: 11))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
                    .frame(width: 120, alignment: .leading)
            }
        }
    }
}
