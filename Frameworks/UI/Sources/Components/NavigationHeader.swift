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

    public var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.largeTitle.bold())

            Spacer()

            ForEach(trailingButtons.indices, id: \.self) { index in
                Button(action: trailingButtons[index].action) {
                    Image(systemName: trailingButtons[index].systemImage)
                        .padding(5)
                }
                .buttonStyle(.glass)
                .clipShape(Circle())
            }
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
}
