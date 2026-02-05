//
//  CreateCollectionSheet.swift
//  App
//
//  Created by Boone on 12/10/25.
//

import ComposableArchitecture
import Models
import SwiftUI

@Reducer
public struct CreateCollectionFeature {
    public init() { }

    @ObservableState
    public struct State: Equatable {
        var collectionName: String = ""
        var selectedCollectionType: CollectionType = .custom

        public init() { }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case tappedCreateButton
        case tappedXButton
        case tappedCollectionType(CollectionType)
    }

    @Dependency(\.movieProvider) var movieProvider
    @Dependency(\.dismiss) var dismiss

    public var body: some ReducerOf<Self> {
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
                // TODO: Add error handling for createCollection failure (PR #13)
                // - Catch errors and display user-facing alert
                // - Consider adding an `error` state property and corresponding alert
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

public struct CreateCollectionSheet: View {
    @Bindable var store: StoreOf<CreateCollectionFeature>

    public init(store: StoreOf<CreateCollectionFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Choose a name")
                    .font(.openSans(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)

                VStack(spacing: 5) {
                    TextField("Collection Name", text: $store.collectionName)
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
                    .accessibilityLabel("Close")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.tappedCreateButton)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    .accessibilityLabel("Create Collection")
                    .buttonStyle(.glassProminent)
                    .tint(.popRed)
                }
            }
        }
    }
}

#Preview {
    CreateCollectionSheet(
        store: Store(
            initialState: CreateCollectionFeature.State(),
            reducer: { CreateCollectionFeature() }
        )
    )
}
