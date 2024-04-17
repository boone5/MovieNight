//
//  TestLoginScreen.swift
//  MovieNight
//
//  Created by Boone on 4/14/24.
//

import SwiftUI

struct TestLoginScreen: View {
    @State private var statusCode: String = "Empty"

    var body: some View {
        Text(statusCode)
            .task {
                let path = "https://ezojrg1lse.execute-api.us-east-2.amazonaws.com/prod/health"
                let url = URL(string: path)!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("xcn1ZrXIys5ueJ1ninaeUaMQHFSEXrrqaGCLFXwg", forHTTPHeaderField: "x-api-key")

                do {
                    let (data, res) = try await URLSession.shared.data(for: request)

                    guard let res = res as? HTTPURLResponse else {
                        return
                    }

                    self.statusCode = res.description
                } catch {
                    print("Error: \(error)")
                }
            }
    }
}

#Preview {
    TestLoginScreen()
}
