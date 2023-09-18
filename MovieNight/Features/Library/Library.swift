//
//  Library.swift
//  MovieNight
//
//  Created by Boone on 9/4/23.
//

import SwiftUI

struct Library: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10, alignment: .center), count: 2)

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 5) {
                Circle()
                    .frame(width: 100, height: 100)

                Text("{user_name}")
                    .font(.title3)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Recently Rated")
                            .font(.title)
                            .padding(.leading, 20)

                        // Move to LazyHStack if performance becomes an issue
                        // https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(0..<5) { _ in
                                Rectangle()
                                    .frame(height: 260)
                                    .foregroundColor(.gray)
                                    .cornerRadius(15)
                                    .overlay(alignment: .bottom) {
                                        RatingsPill()
                                    }
                            }
                        }
                        .padding([.leading, .trailing], 20)
                    }
                }
                .padding(.top, 20)
            }
        }
    }
}

struct RatingsPill: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 50)
                .cornerRadius(15)

            HStack {
                Text("4")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Image(systemName: "star.fill")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
        }
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}
