//
//  BackgroundColorView.swift
//  MovieNight
//
//  Created by Boone on 2/21/25.
//

import SwiftUI

struct BackgroundColorView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            Color.clear
                .background {
                    LinearGradient(
                        colors: [
                            Color("BackgroundColor1"),
                            Color("BackgroundColor2")
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
