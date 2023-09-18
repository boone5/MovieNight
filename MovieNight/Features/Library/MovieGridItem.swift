//
//  MovieGridItem.swift
//  MovieNight
//
//  Created by Boone on 9/13/23.
//

import SwiftUI

struct MovieGridItem: View {
    var body: some View {
        Rectangle()
            .frame(height: 300)
            .foregroundColor(.gray)
            .cornerRadius(15)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .frame(height: 50)
                    .cornerRadius(15)
            }
    }
}

struct MovieGridItem_Previews: PreviewProvider {
    static var previews: some View {
        MovieGridItem()
    }
}
