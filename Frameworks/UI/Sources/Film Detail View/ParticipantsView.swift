//
//  ParticipantsView.swift
//  MovieNight
//
//  Created by Boone on 5/9/25.
//

import SwiftUI

struct ParticipantsView: View {
    let averageColor: UIColor
    let colors = [Color.blue, Color.red, Color.green, Color.purple, Color.blue]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 0) {
                Text("Watched With")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Label {
                    Text("Add")
                } icon: {
                    Image(systemName: "plus")
                }
                .font(.system(size: 14))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.4))
                .clipShape(Capsule())
            }

            HStack(spacing: -20) {
                ForEach(0..<5) { idx in
                    Image(systemName: "plus")
                        .padding(20)
                        .background(colors[idx])
                        .clipShape(Circle())
                        .zIndex(-Double(idx))
                }
            }
        }
        .padding(15)
        .background(Color(uiColor: averageColor).opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    ParticipantsView(averageColor: .red)
}
