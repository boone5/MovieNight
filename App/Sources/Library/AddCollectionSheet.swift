//
//  AddCollectionSheet.swift
//  App
//
//  Created by Boone on 12/10/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AddCollectionFeature {
    @ObservableState
    struct State: Equatable {
        var collectionName: String = ""
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case tappedCreateButton
    }

    @Dependency(\.movieProvider) var movieProvider
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .tappedCreateButton:
                let name = state.collectionName
                return .run { _ in
                    try movieProvider.createCollection(name: name)
                    await dismiss()
                }
            }
        }
    }
}

struct AddCollectionSheet: View {
    @Bindable var store: StoreOf<AddCollectionFeature>

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("What would you like to name your collection?")
                    .font(.title)
                    .multilineTextAlignment(.center)

                TextField("Collection name", text: $store.collectionName)
                    .textFieldStyle(.roundedBorder)

                Button {
                    store.send(.tappedCreateButton)
                } label: {
                    Text("Create")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.collectionName.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
