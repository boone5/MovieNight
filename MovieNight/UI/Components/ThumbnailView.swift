//
//  ThumbnailView.swift
//  MovieNight
//
//  Created by Boone on 2/4/24.
//

import SwiftUI

struct ThumbnailView: View {
    @StateObject var thumbnailViewModel = ThumbnailViewModel()

    let url: String?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            if let imgData = thumbnailViewModel.data, let uiimage = UIImage(data: imgData) {
                Image(uiImage: uiimage)
                    .resizable()
                    .frame(width: width, height: height)
                    .scaledToFit()
                    .cornerRadius(15)
            } else {
                Rectangle()
                    .frame(width: width, height: height)
                    .cornerRadius(15)
            }
        }
        .task {
            await thumbnailViewModel.load(url)
        }
    }
}

#Preview {
    ThumbnailView(url: nil, width: 100, height: 150)
}
