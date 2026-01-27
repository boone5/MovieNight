//
//  CollectionTypeRow.swift
//  App
//
//  Created by Boone on 12/17/25.
//

import Models
import SwiftUI
import UI

struct CollectionTypeButton: View {
    let type: CollectionType
    var isSelected: Bool

    var textColor: Color {
        if isSelected {
            .white
        } else {
            .gray
        }
    }

    var body: some View {
        ThreeColumnLayout(leadingWidth: 30, trailingWidth: 30, spacing: 25) {
            Image(systemName: type.icon)
                .font(.largeTitle)
                .foregroundStyle(textColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(type.title)
                    .font(.openSans(size: 16, weight: .bold))
                    .foregroundStyle(textColor)

                Text(type.subtitle)
                    .font(.openSans(size: 14, weight: .regular))
                    .foregroundStyle(textColor)
            }

            Image(systemName: "checkmark")
                .font(.title2)
                .opacity(isSelected ? 1 : 0)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(Color.popRed)
            }
        }
        .contentShape(Rectangle())
    }
}

struct ThreeColumnLayout: Layout {
    var leadingWidth: CGFloat
    var trailingWidth: CGFloat
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let height = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 3 else { return }

        let leadingSize = subviews[0].sizeThatFits(.unspecified)
        let centerSize = subviews[1].sizeThatFits(.unspecified)
        let trailingSize = subviews[2].sizeThatFits(.unspecified)

        // Leading column: center the icon within leadingWidth
        let leadingX = bounds.minX + (leadingWidth - leadingSize.width) / 2
        let leadingY = bounds.midY - leadingSize.height / 2
        subviews[0].place(at: CGPoint(x: leadingX, y: leadingY), proposal: .unspecified)

        // Center column: starts after leading + spacing, fills remaining space minus trailing
        let centerStartX = bounds.minX + leadingWidth + spacing
        let centerY = bounds.midY - centerSize.height / 2
        subviews[1].place(at: CGPoint(x: centerStartX, y: centerY), proposal: .unspecified)

        // Trailing column: center the checkmark within trailingWidth
        let trailingStartX = bounds.maxX - trailingWidth
        let trailingX = trailingStartX + (trailingWidth - trailingSize.width) / 2
        let trailingY = bounds.midY - trailingSize.height / 2
        subviews[2].place(at: CGPoint(x: trailingX, y: trailingY), proposal: .unspecified)
    }
}
