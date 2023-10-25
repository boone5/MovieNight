//
//  SearchResultDetailView.swift
//  MovieNight
//
//  Created by Boone on 10/18/23.
//

import SwiftUI

struct SearchResultDetailView: View {
    let movie: Movie
    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    self.path.removeLast()
                } label: {
                    Image(systemName: "chevron.left")
                        .buttonStyle(PlainButtonStyle())
                        .foregroundStyle(.black)
                }

                Spacer()

                Button {

                } label: {
                    Text("Legend")
                }
            }
            .padding([.leading, .trailing], 30)
            .padding(.bottom, 20)

            #warning("TODO: Match devices corner radius")
            Rectangle()
                .frame(maxWidth: 300)
                .frame(height: 400)
                .cornerRadius(50)
                .padding(.bottom, 20)

            HStack {
                Text("Rating")
                    .font(.title)

                Spacer()
            }
            .padding([.leading, .trailing], 30)

            HStack(spacing: 5) {
                ForEach(0..<5) { _ in
                    Circle()
                }
            }
            .padding([.leading, .trailing], 30)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden()
    }
}

//#Preview {
//    SearchResultDetailView(movie: MovieMocks().generateMovies(count: 1).results[0]!, path: Binding<NavigationPath>(projectedValue: ))
//}
