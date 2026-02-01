//
//  AddToCollectionSheet.swift
//  Frameworks
//
//  Created by Boone on 1/27/26.
//

import SwiftUI
import Models

// MARK: - Add to Collection Sheet

struct AddToCollectionSheet: View {
    @ObservedObject var viewModel: FilmDetailView.ViewModel
    @Environment(\.dismiss) var dismiss

    private var sortedCollections: [FilmCollection] {
        viewModel.collections.filter {
            $0.id != FilmCollection.recentlyWatchedID
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(sortedCollections.enumerated()), id: \.element.id) { idx, collection in
                        VStack(spacing: 10) {
                            Button {
                                viewModel.toggleCollection(collection.id)
                            } label: {
                                Row(
                                    collection: collection,
                                    isInCollection: viewModel.filmIsInCollection(collection)
                                )
                            }
                            .buttonStyle(.plain)

                            if idx != sortedCollections.count - 1 {
                                Rectangle()
                                    .foregroundStyle(.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                .padding(PLayout.horizontalMarginPadding)
            }
            .background {
                viewModel.averageColor
                .ignoresSafeArea()
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Collection Row

extension AddToCollectionSheet {
    struct Row: View {
        let collection: FilmCollection
        let isInCollection: Bool

        private var posterPaths: [String?] {
            let films = collection.films?.array as? [Film] ?? []
            return films.prefix(3).map { $0.posterPath }
        }

        var body: some View {
            HStack(spacing: 15) {
                PosterFanView(posterPaths: posterPaths)

                VStack(alignment: .leading, spacing: 5) {
                    Text(collection.title ?? "Untitled")
                        .font(.openSans(size: 16, weight: .medium))
                        .foregroundStyle(.white)

                    HStack(spacing: 0) {
                        Group {
                            Text(collection.type.title)
                            Text(" \u{2022} ")
                            Text("\(collection.films?.count ?? 0) films")
                        }
                        .font(.openSans(size: 14))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                    }
                }
                .padding(.leading, 20)

                Spacer()

                if isInCollection {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
    }
}
