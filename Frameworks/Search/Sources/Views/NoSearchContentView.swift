//
//  NoSearchContentView.swift
//  Frameworks
//
//  Created by Ayren King on 12/28/25.
//

import SwiftUI
import UI

struct NoSearchContentView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("What's Pop'n?")
                .font(.montserrat(size: 24, weight: .semibold))

            Text("Find your next movie, tv show, friend, or favorite cast member.")
                .font(.openSans(size: 16))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 15)
    }
}
