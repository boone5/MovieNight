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

                    VStack(spacing: 0) {
                        // Hunter Recommends
                        HStack(alignment: .center) {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)

                            Text("Hunter")
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .regular))

                            Text("suggested")
                                .foregroundStyle(.white).opacity(0.4)
                                .font(.system(size: 14, weight: .thin))

                            Spacer()
                        }
                        .padding(.bottom, 7)
                        .padding(.leading, 15)

                        // Hunter's Recommended
                        HStack {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: 100, height: 125)
                                .foregroundStyle(.gray)
                                .padding(.trailing, 15)

                            VStack(alignment: .leading, spacing: 0) {
                                Text("Bridge to Terabithia")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.bottom, 3)

                                Text("Movie")
                                    .foregroundStyle(Color(uiColor: .systemGray3))
                                    .font(.system(size: 12, weight: .thin))

                                HStack {
                                    ForEach(1..<5) { _ in
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(Color("Gold"))
                                    }

                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(.gray)
                                }
                                .padding(.top, 10)
                            }

                            Spacer()
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.black).opacity(0.1)
                        }

                        // You added
                        HStack(alignment: .center) {
                            Text("You added")
                                .foregroundStyle(.white).opacity(0.4)
                                .font(.system(size: 14, weight: .thin))

                            Spacer()
                        }
                        .padding(.bottom, 5)
                        .padding(.leading, 15)
                        .padding(.top, 15)

                        // Hunter's Recommended
                        HStack {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: 100, height: 125)
                                .foregroundStyle(.gray)
                                .padding(.trailing, 15)

                            VStack(alignment: .leading, spacing: 0) {
                                Text("Bridge to Terabithia")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.bottom, 3)

                                Text("Movie")
                                    .foregroundStyle(Color(uiColor: .systemGray3))
                                    .font(.system(size: 12, weight: .thin))

                                HStack {
                                    ForEach(1..<5) { _ in
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(Color("Gold"))
                                    }

                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(.gray)
                                }
                                .padding(.top, 10)
                            }

                            Spacer()
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.black).opacity(0.1)
                        }

                        // Hunter Recommends
                        HStack(alignment: .center) {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)

                            Text("Hunter")
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .regular))

                            Text("suggested")
                                .foregroundStyle(.white).opacity(0.4)
                                .font(.system(size: 14, weight: .thin))

                            Spacer()
                        }
                        .padding(.bottom, 7)
                        .padding(.leading, 15)
                        .padding(.top, 15)

                        // Hunter's Recommended
                        HStack {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: 100, height: 125)
                                .foregroundStyle(.gray)
                                .padding(.trailing, 15)

                            VStack(alignment: .leading, spacing: 0) {
                                Text("Bridge to Terabithia")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.bottom, 3)

                                Text("Movie")
                                    .foregroundStyle(Color(uiColor: .systemGray3))
                                    .font(.system(size: 12, weight: .thin))

                                HStack {
                                    ForEach(1..<5) { _ in
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(Color("Gold"))
                                    }

                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(.gray)
                                }
                                .padding(.top, 10)
                            }

                            Spacer()
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.black).opacity(0.1)
                        }
                    }
                    .padding([.leading, .trailing, .top], 15)
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
