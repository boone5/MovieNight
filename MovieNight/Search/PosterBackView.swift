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

    @Binding var isFlipped: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView {
                VStack(spacing: 0) {
                    Text("Summary")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .systemGray5))
                        .padding(.top, 30)
                        .padding(.horizontal, 15)

                    Text(film.overview)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                        .padding(.top, 10)
                        .padding(.horizontal, 15)
                        .multilineTextAlignment(.leading)

                    Text("Genre")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .systemGray5))
                        .padding(.top, 20)
                        .padding(.horizontal, 15)

                    Text("Romance, Comedy")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                        .padding(.top, 10)
                        .padding(.horizontal, 15)

                    Text("Where to watch")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .systemGray5))
                        .padding(.top, 20)
                        .padding(.horizontal, 15)

                    Text("Random Logo 1, Random Logo 2")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                        .padding(.top, 10)
                        .padding(.horizontal, 15)

                    Text("Release Date")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .systemGray5))
                        .padding(.top, 20)
                        .padding(.horizontal, 15)

                    Text("August 15th, 2021")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                        .padding(.top, 10)
                        .padding(.horizontal, 15)

                    Text("Duration")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .systemGray5))
                        .padding(.top, 20)
                        .padding(.horizontal, 15)

                    Text("2 hrs, 10 min")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                        .padding(.top, 10)
                        .padding(.horizontal, 15)

                    Text("Cast")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .systemGray5))
                        .padding(.top, 20)
                        .padding(.horizontal, 15)

                    ScrollView(.horizontal) {
                        HStack(spacing: 15) {
                            ForEach(1..<5) { _ in
                                VStack {
                                    Circle()
                                        .frame(width: 60, height: 60)
                                        .foregroundStyle(Color(uiColor: .systemGray4))

                                    Text("Leonardo")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(Color(uiColor: .systemGray2))
                                }
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 45)
                    }
                }
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color(uiColor: backgroundColor))
            }

            Text("Cover")
                .font(.system(size: 12))
                .foregroundStyle(.white)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color.gray.opacity(0.2))
                        .shadow(radius: 3, y: 4)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        isFlipped.toggle()
                    }
                }
                .padding([.bottom, .leading], 15)
        }
    }
}
