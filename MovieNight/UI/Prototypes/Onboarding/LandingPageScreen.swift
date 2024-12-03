//
//  LandingPageScreen.swift
//  MovieNight
//
//  Created by Boone on 4/14/24.
//

import SwiftUI

struct LandingPageScreen: View {
    var body: some View {
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

            VStack(spacing: 20) {
                // TODO: 3D graphic with popcorn
                Text("Pop'n")
                    .foregroundStyle(.white)
                    .font(.system(size: 42, weight: .bold))
                    .padding([.leading, .trailing], 15)
                    .padding(.bottom, 10)

                Button {
                    print("Navigating to Create Account")
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color("Gold"))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                            .padding([.leading, .trailing], 30)

                        HStack {
                            Text("Create account")
                                .foregroundStyle(Color.black)
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                    }
                }

                Button {
                    print("Navigating to Log in")
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color("BrightRed"))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                            .padding([.leading, .trailing], 30)

                        HStack {
                            Text("Log in")
                                .foregroundStyle(Color.white)
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                    }
                }

                // TODO: Open Modal
                Text("Do I need an account?")
                    .foregroundStyle(Color.white)
            }
        }
    }
}

#Preview {
    LandingPageScreen()
}
