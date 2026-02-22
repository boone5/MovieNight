//
//  AddToCollectionSheet.swift
//  App
//

import ComposableArchitecture
import Models
import SwiftUI

@ViewAction(for: AddToCollectionFeature.self)
public struct AddToCollectionSheet: View {
    @Environment(\.dismiss) var dismiss

    public let store: StoreOf<AddToCollectionFeature>

    public init(store: StoreOf<AddToCollectionFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(store.collectionModels.enumerated(), id: \.element.id) { idx, model in
                        VStack(spacing: 10) {
                            Button {
                                send(.collectionToggled(model))
                            } label: {
                                row(for: model)
                            }
                            .buttonStyle(.plain)

                            if idx != store.collectionModels.count - 1 {
                                Rectangle()
                                    .foregroundStyle(.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                        }
                    }
                }
                .padding(PLayout.horizontalMarginPadding)
                .frame(maxWidth: .infinity)
            }
            .background {
                if let customBackgroundColor = store.customBackgroundColor {
                    customBackgroundColor
                        .overlay(Color.black.opacity(0.5))
                        .ignoresSafeArea()
                } else {
                    Color.background
                        .ignoresSafeArea()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add to Collection")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // Calling Environment dismiss until MediaDetailView supports TCA
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                }
            }
            .interactiveDismissDisabled()
        }
        .task {
            send(.onTask)
        }
    }

    private func isFilmInCollection(_ collection: CollectionModel) -> Bool {
        collection.posterPaths.contains { $0 == store.media.posterPath }
    }

    private func row(for model: CollectionModel) -> some View {
        let textColor: Color = store.customBackgroundColor == nil ? .primary : .white

        return HStack(spacing: 15) {
            PosterFanView(posterPaths: model.posterPaths, collectionType: model.type)
                .animation(.default, value: isFilmInCollection(model))

            VStack(alignment: .leading, spacing: 5) {
                Text(model.title)
                    .font(.openSans(size: 18, weight: .semibold))
                    .foregroundStyle(textColor)

                HStack(spacing: 0) {
                    Group {
                        Text(model.type.title)
                        Text(" \u{2022} ")
                        Text("\(model.filmCount) films")
                            .contentTransition(.numericText())
                    }
                    .font(.openSans(size: 16))
                    .foregroundStyle(Color(uiColor: .systemGray2))
                }
            }
            .padding(.leading, 20)

            Spacer()

            if isFilmInCollection(model) {
                Image(systemName: "checkmark")
                    .foregroundStyle(textColor)
                    .font(.system(size: 18, weight: .semibold))
                    .transition(.scale)
            }
        }
        .contentShape(.rect)
        .animation(.interactiveSpring, value: isFilmInCollection(model))
    }
}
