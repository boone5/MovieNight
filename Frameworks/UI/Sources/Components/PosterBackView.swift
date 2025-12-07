//
//  FilmBottomSheetView.swift
//  MovieNight
//
//  Created by Boone on 9/12/24.
//

import Models
import Networking
import SwiftUI
import UI

struct PosterBackView: View {
    let film: DetailViewRepresentable
    let backgroundColor: Color

    @Binding var trailer: AdditionalDetailsMovie.VideoResponse.Video?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView {
                VStack(spacing: 15) {
                    Text("Summary")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white).opacity(0.6)

                    Text(film.overview ?? "")
                        .font(.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.leading)
                        .padding(.top, -5)

                    Text("Release Date")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white).opacity(0.6)

                    Text("August 15th, 2021")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .regular))
                        .padding(.top, -5)

                    Text("Duration")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white).opacity(0.6)

                    Text("2 hrs, 10 min")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .regular))
                        .padding(.top, -5)

                    if let trailer, let key = trailer.key {
                        Text("Trailer")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white).opacity(0.6)

                        TrailerView(videoID: key)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(backgroundColor)
            }
        }
    }
}
