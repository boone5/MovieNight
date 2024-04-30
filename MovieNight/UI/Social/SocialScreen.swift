//
//  SocialScreen.swift
//  MovieNight
//
//  Created by Boone on 4/18/24.
//

import SwiftUI

struct SocialScreen: View {
    @State private var hasAccess: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .background {
                        LinearGradient(
                            colors: [Color("BackgroundColor2"), Color("BackgroundColor1")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Social")
                            .foregroundStyle(.white)
                            .font(.system(size: 42, weight: .bold))
                            .padding([.leading, .trailing], 15)
                            .padding(.bottom, 10)

                        ScrollView(.horizontal) {
                            HStack(spacing: 15) {
                                ForEach(1..<6) { _ in
                                    Circle()
                                        .frame(width: 75, height: 75)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .safeAreaInset(edge: .leading, spacing: 0) {
                            VStack(spacing: 0) { }.padding(.leading, 15)
                        }
                        .safeAreaInset(edge: .trailing, spacing: 0) {
                            VStack(spacing: 0) { }.padding(.trailing, 15)
                        }
                        .padding(.bottom, 10)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            }
            .onAppear {
                hasAccess = true
            }
        }
    }
}

#Preview {
    SocialScreen()
}
