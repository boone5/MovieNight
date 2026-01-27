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
    let averageColor: Color

    @State private var showAddCollectionSheet = false

    /// Collections sorted with already-added ones at the top
    private var sortedCollections: [FilmCollection] {
        viewModel.collections.sorted { lhs, rhs in
            let lhsContains = viewModel.filmIsInCollection(lhs)
            let rhsContains = viewModel.filmIsInCollection(rhs)
            if lhsContains != rhsContains {
                return lhsContains // Already-added collections first
            }
            return (lhs.dateCreated ?? .distantPast) < (rhs.dateCreated ?? .distantPast)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(sortedCollections.enumerated()), id: \.element.id) { idx, collection in
                        VStack(spacing: 10) {
                            Button {
                                viewModel.addToCollection(collection.id)
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
                        .padding(.vertical, 5)
                    }
                }
                .padding(PLayout.horizontalMarginPadding)
            }
            .background {
                averageColor
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

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddCollectionSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
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

        var body: some View {
            HStack(spacing: 15) {
                PosterFanView(items: ["1", "2", "3"])

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
                        .foregroundStyle(.green)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
    }
}
