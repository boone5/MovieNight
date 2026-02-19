//
//  MediaCollectionPicker.swift
//  Frameworks
//
//  Created by Ayren King on 1/27/26.
//

import Models
import SwiftUI
import UI

struct MediaCollectionPicker: View {
    let collections: FetchedResults<FilmCollection>
    let previousSelectedCollectionID: FilmCollection.ID?
    @State var newCollection: FilmCollection.ID?
    @State private var sheetHeight: CGFloat = .zero
    let onCollectionPickerValueUpdated: (FilmCollection.ID?) -> Void

    init(
        collections: FetchedResults<FilmCollection>,
        selectedCollectionID: FilmCollection.ID?,
        onCollectionPickerValueUpdated: @escaping (FilmCollection.ID?) -> Void
    ) {
        self.collections = collections
        self.previousSelectedCollectionID = selectedCollectionID
        self._newCollection = .init(initialValue: selectedCollectionID)
        self.onCollectionPickerValueUpdated = onCollectionPickerValueUpdated
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $newCollection) {
                    Text("No collection").tag(FilmCollection.ID?.none)
                    ForEach(collections) { collection in
                        Text(collection.safeTitle).tag(Optional(collection.id))
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("Pick a Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
                        onCollectionPickerValueUpdated(previousSelectedCollectionID)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "arrow.up") {
                        onCollectionPickerValueUpdated(newCollection)
                    }
                    .tint(.popRed)
                }
            }
            .recordViewHeight(for: $sheetHeight)
            .presentationDetents(sheetHeight > 0 ? [.height(sheetHeight)] : [.medium])
        }
    }
}

extension View {
    func recordViewHeight(for height: Binding<CGFloat>) -> some View {
        self
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self) {
                $0.size.height
            } action: { newValue in
                height.wrappedValue = newValue
            }
    }
}
