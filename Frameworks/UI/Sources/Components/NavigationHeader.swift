//
//  NavigationHeader.swift
//  UI
//
//  Created by Boone on 12/12/25.
//

import SwiftUI

public struct NavigationHeaderButton {
    let systemImage: String
    let action: () -> Void

    public init(systemImage: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.action = action
    }
}

public struct NavigationHeader: View {
    let title: String
    let trailingButtons: [NavigationHeaderButton]

    public init(title: String, trailingButtons: [NavigationHeaderButton] = []) {
        self.title = title
        self.trailingButtons = trailingButtons
    }

    @State private var headerOpacity: Double = 1.0

    public var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.montserrat(size: 34, weight: .semibold))

            Spacer()

            ForEach(trailingButtons.indices, id: \.self) { index in
                Button(action: trailingButtons[index].action) {
                    Image(systemName: trailingButtons[index].systemImage)
                        .padding(5)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
            }
        }
        .opacity(headerOpacity)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.frame(in: .scrollView).minY
        } action: { minY in
            let fadeThreshold = 50.0
            headerOpacity = max(0, min(1, (minY + fadeThreshold) / fadeThreshold))
        }
    }
}

#Preview {
    NavigationHeader(
        title: "Library",
        trailingButtons: [
            NavigationHeaderButton(systemImage: "magnifyingglass") {},
            NavigationHeaderButton(systemImage: "plus") {}
        ]
    )
    .padding()
    .loadCustomFonts()
}
