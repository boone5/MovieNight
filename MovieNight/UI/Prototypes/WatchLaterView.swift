//
//  WatchLaterView.swift
//  MovieNight
//
//  Created by Boone on 1/9/25.
//

import SwiftUI

struct WatchLaterView: View {
    // In your real app, you'll likely pass these in or fetch from elsewhere
    @State private var items: [ChecklistItem] = [
        ChecklistItem(title: "Buy groceries", mediaType: "Movie"),
        ChecklistItem(title: "Walk the dog", mediaType: "TV Show"),
        ChecklistItem(title: "Feed the cat", mediaType: "TV Show"),
        ChecklistItem(title: "Water the plants", mediaType: "Movie"),
        ChecklistItem(title: "Pay bills", mediaType: "TV Show"),
        ChecklistItem(title: "Read a book", mediaType: "Movie") // More than 5, so it tests `prefix(5)`
    ]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Want to watch")
                .foregroundStyle(.white)
                .font(.system(size: 22, weight: .bold))
                .padding([.leading, .trailing], 15)

            ScrollView(.horizontal) {
                // Only show the first 5 items
                HStack(spacing: 10) {
                    ForEach(items.prefix(5)) { item in
                        VStack(spacing: 10) {
                            if item.isComplete {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.gray)
                                    .frame(width: 100, height: 150)

                            } else {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.gray)
                                    .frame(width: 100, height: 150)
                            }
                        }
                        .contentShape(Rectangle()) // Makes the entire row tappable
                    }
                }
                .padding([.leading, .trailing], 15)
            }

        }
    }
}

struct ChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let mediaType: String
    var isComplete: Bool = false
}

#Preview {
    WatchLaterView()
}
