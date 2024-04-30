//
//  CreateAccountScreen.swift
//  MovieNight
//
//  Created by Boone on 4/29/24.
//

import SwiftUI

struct CreateAccountScreen: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

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

            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome!")
                    .foregroundStyle(.white)
                    .font(.system(size: 42, weight: .bold))
                    .padding([.leading, .trailing], 15)

                Text("Username")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding([.leading, .trailing], 45)

                Rectangle()
                    .frame(height: 45)
                    .foregroundStyle(Color(uiColor: UIColor.systemGray4))
                    .cornerRadius(.infinity)
                    .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                    .overlay {
                        TextField("Username", text: $username)
                            .padding(15)
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 30)
                    .padding([.top], -10)
                    .textFieldStyle(.plain)

                Text("Password")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding([.leading, .trailing], 45)

                Rectangle()
                    .frame(height: 45)
                    .foregroundStyle(Color(uiColor: UIColor.systemGray4))
                    .cornerRadius(.infinity)
                    .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                    .overlay {
                        TextField("Password", text: $password)
                            .padding(15)
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 30)
                    .padding([.top], -10)
                    .textFieldStyle(.plain)

                Text("Confirm Password")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding([.leading, .trailing], 45)

                Rectangle()
                    .frame(height: 45)
                    .foregroundStyle(Color(uiColor: UIColor.systemGray4))
                    .cornerRadius(.infinity)
                    .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                    .overlay {
                        TextField("Confirm Password", text: $confirmPassword)
                            .padding(15)
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 30)
                    .padding([.top], -10)
                    .textFieldStyle(.plain)

                Button {
                    // TODO: Network request to backend
                    print("Attempting to Create Account")
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color("BrightRed"))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                            .padding([.leading, .trailing], 30)

                        HStack {
                            Text("Create account")
                                .foregroundStyle(Color.white)
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding([.top], 10)

            }
        }
    }

    private func createAccount() async {
        do {
            let loginRequest = LoginRequest(username: username, password: password)
            let encoded = try JSONEncoder().encode(loginRequest)

            let url = try NetworkManager().createURL(from: LoginEndpoint.login)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(APIKey.key_AWS, forHTTPHeaderField: "x-api-key")
            request.httpBody = encoded

            let (data, res) = try await URLSession.shared.data(for: request)

            guard let res = res as? HTTPURLResponse else {
                return
            }

            //                self.statusCode = res.description
        } catch {
            print("Error: \(error)")
        }
    }

    struct LoginRequest: Encodable {
        let username: String
        let password: String
    }
}

#Preview {
    CreateAccountScreen()
}
