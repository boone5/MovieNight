//
//  MediaCollectionPicker.swift
//  Frameworks
//
//  Created by Ayren King on 1/27/26.
//

import SwiftUI
import UI

struct MediaCollectionPicker: View {
    @Environment(\.dismiss) var dismiss

    @Binding var selectedCollection: String?
    @State var newCollection: String?
    @State private var sheetHeight: CGFloat = .zero

    init(selectedCollection: Binding<String?>) {
        self._selectedCollection = selectedCollection
        self._newCollection = .init(wrappedValue: selectedCollection.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $newCollection) {
                    Text("No collection").tag(String?.none)
                    ForEach(
                        ["Watch List", "In Theaters Now", "Trending Movies", "Custom List #1", "Custom List #2"],
                        id: \.self
                    ) { collection in
                        Text(collection).tag(Optional(collection))
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("Pick a Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "arrow.up") {
                        selectedCollection = newCollection
                        dismiss()
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
