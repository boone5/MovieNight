//
//  ContentView.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import SwiftUI

struct ContentView: View {
    let networkLayer = NetworkLayer()

    var body: some View {
        Text("Hello World")
        .task {
            await networkLayer.sendRequest()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
