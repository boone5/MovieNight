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
            Color.clear
                .background {
                    LinearGradient(
                        colors: [
                            UIAsset.backgroundColor1.swiftUIColor,
                            UIAsset.backgroundColor2.swiftUIColor
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()

            content()
        }
    }
}

#Preview {
    BackgroundColorView {
        Text("Hello World")
    }
}
