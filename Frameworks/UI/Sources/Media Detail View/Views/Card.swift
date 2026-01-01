//
//  Card.swift
//  Frameworks
//
//  Created by Ayren King on 12/28/25.
//

import SwiftUI

public struct Card<Content: View>: View {
    let averageColor: Color
    let content: () -> Content

    public init(averageColor: Color, @ViewBuilder content: @escaping () -> Content) {
        self.averageColor = averageColor
        self.content = content
    }

    public var body: some View {
        VStack {
            content()
        }
        .padding(20)
        .background(averageColor.opacity(0.4))
        .cornerRadius(12)
    }
}
