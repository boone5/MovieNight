//
//  CollectionDetailView.swift
//  MovieNight
//
//  Created by Boone on 2/18/25.
//

import SwiftUI

struct CollectionDetailView: View {
    let title: String?
    let films: [Film]

    var body: some View {
        ZStack {
            Color.clear
                .background {
                    LinearGradient(
                        colors: [Color("BackgroundColor1"), Color("BackgroundColor2")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Hello World")
            }
        }
        .navigationTitle(title ?? "-")
    }
}

#Preview {
    CollectionDetailView(title: "Hello World", films: [])
}
