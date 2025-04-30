//
//  SeasonProgressView.swift
//  MovieNight
//
//  Created by Boone on 4/7/25.
//

import SwiftUI

struct SeasonProgressView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Seasons")
                    .font(.system(size: 16, weight: .bold))

                Spacer()

                Text("0%")
                    .font(.system(size: 16, weight: .regular))
            }

            SeasonView()
        }
        .padding(.horizontal, 15)
    }

    struct SeasonView: View {
        var body: some View {
            VStack {
                Text("Season 1")
                    .font(.system(size: 14, weight: .semibold))
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                Text("36 episodes")
                    .font(.system(size: 14, weight: .regular))
            }
            .padding()
            .background {
                Color.gray
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
    }
}

#Preview {
    SeasonProgressView()
}
