//
//  AvatarPickerSheet.swift
//  Frameworks
//
//  Created by Ayren King on 1/30/26.
//

import UI
import SwiftUI

struct AvatarPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: String
    var onConfirm: () -> Void

    private let options: [String] = [
        "person.fill", "person.circle.fill", "bolt.fill", "star.fill", "heart.fill",
        "globe", "gamecontroller.fill", "book.fill", "music.note", "leaf.fill",
        "flame.fill", "pawprint.fill", "bicycle", "camera.fill", "paperplane.fill"
    ]

    private let columns = [GridItem(.adaptive(minimum: 64), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(options, id: \.self) { symbol in
                        Button {
                            selection = symbol
                        } label: {
                            VStack {
                                Circle()
                                    .fill(selection == symbol ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1))
                                    .frame(width: 64, height: 64)
                                    .overlay {
                                        Image(systemName: symbol)
                                            .font(.system(size: 28, weight: .regular))
                                            .foregroundStyle(.primary)
                                    }
                                    .overlay {
                                        if selection == symbol {
                                            Circle()
                                                .stroke(Color.accentColor, lineWidth: 2)
                                        }
                                    }
                                Text(symbol)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Avatar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        onConfirm()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
