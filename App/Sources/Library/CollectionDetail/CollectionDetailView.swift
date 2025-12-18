//
//  CollectionDetailView.swift
//  MovieNight
//
//  Created by Boone on 2/18/25.
//

import Models
import SwiftUI
import UI

struct CollectionDetailView: View {
    let title: String
    let films: [Film]
    @Binding var selectedFilm: SelectedFilm?

    @Namespace private var namespace

    var body: some View {
        BackgroundColorView {
            ScrollView {
                VStack {
                    WatchList(
                        watchList: films,
                        namespace: namespace,
                        selectedFilm: $selectedFilm
                    )
                }
                .padding(.horizontal, PLayout.horizontalMarginPadding)
                .padding(.bottom, PLayout.bottomMarginPadding)
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // todo
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedFilm: SelectedFilm? = nil
    CollectionDetailView(title: "Some Title", films: [], selectedFilm: $selectedFilm)
}
