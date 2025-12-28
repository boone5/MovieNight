//
//  NoMoreResultsView.swift
//  Frameworks
//
//  Created by Ayren King on 12/28/25.
//

import SwiftUI
import UI

struct NoMoreResultsView: View {
    @State private var appeared = false

    var body: some View {
        Text("No more results")
            .font(.openSans(size: 14, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .opacity(appeared ? 1 : 0)
            .animation(.easeIn(duration: 0.25), value: appeared)
            .onAppear { appeared = true }
    }
}
