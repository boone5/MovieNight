//
//  FilmBottomSheetView.swift
//  MovieNight
//
//  Created by Boone on 9/12/24.
//

import SwiftUI

struct PosterBackView: View {
    let film: DetailViewRepresentable
    let backgroundColor: UIColor

    @Binding var trailer: AdditionalDetailsMovie.VideoResponse.Video?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView {
                VStack(spacing: 0) {
                    Text("Summary")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white).opacity(0.6)
                        .padding(.top, 30)
                        .padding(.horizontal, 15)

                    Text(film.overview ?? "")
                        .font(.system(size: 14, weight: .regular))
                        .padding(.top, 10)
                        .padding(.horizontal, 15)
                        .multilineTextAlignment(.leading)

                    if let trailer, let key = trailer.key {
                        Text("Trailer")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white).opacity(0.6)
                            .padding(.top, 30)
                            .padding(.horizontal, 15)

                        TrailerView(videoID: key)
                            .padding(.top, 10)
                            .padding(.horizontal, 15)
                    }

                    Text("Where to watch")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white).opacity(0.6)
                        .padding(.top, 30)
                        .padding(.horizontal, 15)

                    Text("Random Logo 1, Random Logo 2")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .regular))
                        .padding(.top, 10)
                        .padding(.horizontal, 15)

                    Text("Release Date")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white).opacity(0.6)
                        .padding(.top, 30)
                        .padding(.horizontal, 15)

                    Text("August 15th, 2021")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .regular))
                        .padding(.top, 10)
                        .padding(.horizontal, 15)

                    Text("Duration")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white).opacity(0.6)
                        .padding(.top, 30)
                        .padding(.horizontal, 15)

                    Text("2 hrs, 10 min")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .regular))
                        .padding(.top, 10)
                        .padding(.horizontal, 15)
                }
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color(uiColor: backgroundColor))
            }
        }
    }
}
