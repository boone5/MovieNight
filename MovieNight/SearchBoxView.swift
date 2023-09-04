//
//  SearchBoxView.swift
//  MovieNight
//
//  Created by Boone on 8/28/23.
//

import SwiftUI

struct SearchBoxView: View {

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

                // MARK: TODO - Cycle Text with different prompts
                TextField("What movie are you looking for?", text: $textField)
                    .foregroundColor(Color(.black))
            }
        }
    }
}

struct SearchBoxView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBoxView()
    }
}
