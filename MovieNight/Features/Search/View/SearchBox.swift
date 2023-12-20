//
//  SearchBoxView.swift
//  MovieNight
//
//  Created by Boone on 8/28/23.
//

import SwiftUI

struct SearchBox: View {
    @ObservedObject var searchViewModel: SearchViewModel
    
    @State private var textField: String = ""

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(height: 40)
                .cornerRadius(15)
                .foregroundColor(Color(.systemGray5))

            HStack(spacing: 20) {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 20)
                    .foregroundColor(Color(.darkGray))

                #warning("TODO: Cycle Text with different prompts?")
                TextField("What movie are you looking for?", text: $textField)
                    .foregroundColor(Color(.black))
                    .onSubmit {
                        #warning("TODO: Debouncer?")
                        Task {
                            print("Query for \(textField)")
                            await searchViewModel.fetchMovies(for: textField)
                        }
                    }
            }
        }
    }
}

struct SearchBox_Previews: PreviewProvider {
    static var previews: some View {
        SearchBox(searchViewModel: SearchViewModel())
    }
}
