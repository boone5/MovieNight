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
    @Bindable var viewModel: MediaDetailViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.collectionModels.enumerated(), id: \.element.id) { idx, model in
                        VStack(spacing: 10) {
                            Button {
                                viewModel.toggleCollection(model)
                            } label: {
                                Row(viewModel: viewModel, model: model)
                            }
                            .buttonStyle(.plain)

                            if idx != viewModel.collectionModels.count - 1 {
                                Rectangle()
                                    .foregroundStyle(.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                .padding(PLayout.horizontalMarginPadding)
                .frame(maxWidth: .infinity)
            }
            .background {
                viewModel.averageColor
                .ignoresSafeArea()
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                }
            }
            .interactiveDismissDisabled()
        }
    }
}

// MARK: - Collection Row

extension AddToCollectionSheet {
    struct Row: View {
        @Bindable var viewModel: MediaDetailViewModel
        let model: CollectionModel

        var body: some View {
            HStack(spacing: 15) {
                PosterFanView(posterPaths: model.posterPaths, collectionType: model.type)

                VStack(alignment: .leading, spacing: 5) {
                    Text(model.title)
                        .font(.openSans(size: 16, weight: .medium))
                        .foregroundStyle(.white)

                    HStack(spacing: 0) {
                        Group {
                            Text(model.type.title)
                            Text(" \u{2022} ")
                            Text("\(model.filmCount) films")
                        }
                        .font(.openSans(size: 14))
                        .foregroundStyle(Color(uiColor: .systemGray2))
                    }
                }
                .padding(.leading, 20)

                Spacer()

                if viewModel.isFilmInCollection(model) {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .contentShape(.rect)
        }
    }
}
