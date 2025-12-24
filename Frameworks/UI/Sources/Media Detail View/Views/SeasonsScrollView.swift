//
//  SeasonsScrollView.swift
//  Frameworks
//
//  Created by Ayren King on 12/23/25.
//

import SwiftUI

struct SeasonsScrollView: View {
    var viewModel: MediaDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Seasons Watched")
                .font(.montserrat(size: 16, weight: .semibold))
                .foregroundStyle(.white)

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(viewModel.seasons, id: \.id) { season in
                        SeasonPosterView(
                            posterPath: season.posterPath,
                            seasonNum: season.number,
                            averageColor: viewModel.averageColor
                        )
                    }
                }
                .padding([.horizontal], 30)
            }
            .scrollIndicators(.hidden)
            .padding([.horizontal], -30)
        }
        .padding(20)
        .background(viewModel.averageColor.opacity(0.4))
        .cornerRadius(12)
    }
}
