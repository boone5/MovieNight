//
//  AddCollectionSheet.swift
//  App
//
//  Created by Boone on 12/10/25.
//

import ComposableArchitecture
import Models
import SwiftUI
import UI

@Reducer
struct AddCollectionFeature {
    @ObservableState
    struct State: Equatable {
        var collectionName: String = ""
        var selectedCollectionType: CollectionType = .custom
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case tappedCreateButton
        case tappedXButton
        case tappedCollectionType(CollectionType)
    }

    @Dependency(\.movieProvider) var movieProvider
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .tappedXButton:
                return .run { _ in
                    await dismiss()
                }

            case .tappedCreateButton:
                let name = state.collectionName
                let type = state.selectedCollectionType
                return .run { _ in
                    try movieProvider.createCollection(name: name, type: type)
                    await dismiss()
                }

            case let .tappedCollectionType(type):
                state.selectedCollectionType = type
                return .none
            }
        }
    }
}

public struct AddCollectionSheet: View {
    @Bindable var store: StoreOf<AddCollectionFeature>

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Choose a name")
                    .font(.openSans(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)

                VStack(spacing: 5) {
                    TextField("", text: $store.collectionName)
                        .textFieldStyle(.plain)
                        .font(.openSans(size: 28))

                    Divider()
                }

                Text("Select one")
                    .font(.openSans(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)

                VStack(spacing: 15) {
                    ForEach(CollectionType.allCases, id: \.self) { type in
                        Button {
                            store.send(.tappedCollectionType(type))
                        } label: {
                            CollectionTypeButton(
                                type: type,
                                isSelected: store.selectedCollectionType == type
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, PLayout.horizontalMarginPadding)
            .padding(.top, 20)
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.send(.tappedXButton)
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

                // TODO: apply coloring from design system
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.tappedCreateButton)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.popRed)
                }
            }
        }
    }
}

#Preview {
    AddCollectionSheet(
        store: Store(
            initialState: AddCollectionFeature.State(),
            reducer: { AddCollectionFeature() }
        )
    )
}
