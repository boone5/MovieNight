//
//  LibraryTest.swift
//  MovieNight
//
//  Created by Boone on 3/2/24.
//

import SwiftUI

struct LibraryTest: View {
    var body: some View {

        ZStack {
//            Color("DarkRed")
//                .ignoresSafeArea()

            VStack {
                Text("Library")
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)

                ScrollView {

                    ItemView()
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
            }
        }

    }
}

struct ItemView: View {
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                ButtonView()

                HStack {
                    ForEach(1..<6) { _ in
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("Gold"))
                            .shadow(color: Color("Gold").opacity(0.2), radius: 4)
                    }

                }
            }

            Rectangle()
                .foregroundColor(.gray)
                .frame(width: 175, height: 240)
                .scaledToFit()
                .cornerRadius(15)
        }

    }
}

struct ButtonView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color("OffBlack"))
                .frame(width: 175, height: 35)
                .shadow(color: Color.black.opacity(0.6), radius: 6, x: 0, y: 4)

            Color.clear
                .cornerRadius(10)
                .frame(width: 250)

        }
    }
}

#Preview {
    LibraryTest()
}
