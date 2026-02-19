//
//  BackgroundColorView.swift
//  MovieNight
//
//  Created by Boone on 2/21/25.
//

import SwiftUI

public struct BackgroundColorView<Content: View>: View {
    let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            content()
        }
    }
}

#Preview {
    BackgroundColorView {
        Text("Hello World")
    }
}
