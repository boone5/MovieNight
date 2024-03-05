//
//  MarqueeLightFrameView.swift
//  MovieNight
//
//  Created by Boone on 3/3/24.
//

import SwiftUI

struct MarqueeLightFrameView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 175, height: 35)
                .foregroundColor(Color("OffBlack"))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.6), radius: 6, x: 0, y: 4)

            HStack(spacing: 40) {
                ForEach(1..<4) { _ in
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color("Gold"))
                        .shadow(color: Color("Gold").opacity(0.7), radius: 8)
                }
            }
        }
        .offset(y: -150)

        ZStack {
            Rectangle()
                .frame(width: 35)
                .foregroundColor(Color("OffBlack"))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.6), radius: 6, x: -4, y: 0)

            VStack(spacing: 25) {
                ForEach(1..<6) { _ in
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color("Gold"))
                        .shadow(color: Color("Gold").opacity(0.7), radius: 8)
                }
            }
        }
        .offset(x: 115)

        ZStack {
            Rectangle()
                .frame(width: 35)
                .foregroundColor(Color("OffBlack"))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.6), radius: 6, x: 4, y: 0)

            VStack(spacing: 25) {
                ForEach(1..<6) { _ in
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color("Gold"))
                        .shadow(color: Color("Gold").opacity(0.7), radius: 8)
                }
            }
        }
        .offset(x: -115)

        ZStack {
            Rectangle()
                .frame(width: 175, height: 35)
                .foregroundColor(Color("OffBlack"))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.6), radius: 6, x: 0, y: -4)

            HStack(spacing: 40) {
                ForEach(1..<4) { _ in
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color("Gold"))
                        .shadow(color: Color("Gold").opacity(0.7), radius: 8)
                }
            }
        }
        .offset(y: 150)
    }
}
