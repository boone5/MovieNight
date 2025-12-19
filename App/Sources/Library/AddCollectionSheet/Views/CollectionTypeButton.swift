//
//  CollectionTypeRow.swift
//  App
//
//  Created by Boone on 12/17/25.
//

import SwiftUI

struct CollectionTypeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    var isSelected: Bool

    var body: some View {
        ThreeColumnLayout(leadingWidth: 30, trailingWidth: 30, spacing: 25) {
            Image(systemName: icon)
                .font(.largeTitle)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .medium))

                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "checkmark")
                .font(.title2)
                .opacity(isSelected ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.secondary)
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
