//
//  NetworkLayer.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import Foundation

class NetworkLayer {
    let headers = [
        "X-RapidAPI-Key": "23a15db573mshe9f036d0688007bp1d8ea0jsn4c70d99f389b",
        "X-RapidAPI-Host": "moviesdatabase.p.rapidapi.com"
    ]

    func sendRequest() async {
        let url = URL(string: "https://moviesdatabase.p.rapidapi.com/titles/search/title/uncorked?exact=false&titleType=movie")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)

        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared

        do {
            let (data, _) = try await session.data(for: request)

            let obj = try JSONDecoder().decode(Results.self, from: data)

            print("hello")
        } catch {
            print(error)
        }
    }
}
