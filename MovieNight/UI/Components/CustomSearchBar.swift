//
//  CustomSearchBar.swift
//  MovieNight
//
//  Created by Boone on 3/13/24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 18)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.gray.opacity(0.3))
                .overlay(alignment: .leading) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Seach Box", text: $searchText, prompt: Text("Search"))
                    }
                    .padding(.leading, 15)
                }
                .animation(.easeInOut, value: searchText)

            if !searchText.isEmpty {
                Text("Cancel")
            }
        }
    }
}

#Preview {
    @Previewable @State var searchText = ""
    SearchBar(searchText: $searchText)
}
