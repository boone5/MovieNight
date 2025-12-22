//
//  ActionView.swift
//  MovieNight
//
//  Created by Boone on 8/2/25.
//

import SwiftUI

struct ActionView<Content: View>: View {
    let averageColor: Color
    let content: () -> Content

    var body: some View {
        VStack {
            content()
        }
        .padding(15)
        .background(averageColor.opacity(0.4))
        .cornerRadius(12)
    }
}

struct WatchedAtView: View {
    let averageColor: Color

    let labels = ["Home", "Theater", "Outdoors", "Plane", "Train", "Car", "Add"]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Watched at")
                    .font(.montserrat(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()
            }

            FlowLayout(spacing: 10, verticalSpacing: 10) {
                ForEach(labels, id: \.self) { label in
                    Label {
                        Text(label)
                            .font(.openSans(size: 14))
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "house")
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                    .background(Color.blue.opacity(0.4))
                    .cornerRadius(12)
                }
            }
        }
        .padding(15)
        .background(averageColor.opacity(0.4))
        .cornerRadius(12)
    }
}

#Preview {
    WatchedAtView(averageColor: .red)
        .loadCustomFonts()
}
