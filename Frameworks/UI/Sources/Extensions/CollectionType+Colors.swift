//
//  CollectionType+Colors.swift
//  UI
//
//  Created by Boone on 12/29/25.
//

import SwiftUI
import Models

extension CollectionType {
    public var buttonBackgroundGradient: LinearGradient {
        switch self {
        case .custom:
            // Deep Purple Gradient
            LinearGradient(
                colors: [Color(red: 0.45, green: 0.25, blue: 0.65), Color(red: 0.30, green: 0.15, blue: 0.50)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ranked:
            // Burnt Orange Gradient
            LinearGradient(
                colors: [Color(red: 0.80, green: 0.35, blue: 0.15), Color(red: 0.60, green: 0.25, blue: 0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .smart:
            // Vibrant Rainbow Gradient - saturated colors for contrast
            LinearGradient(
                colors: [
                    Color(red: 0.85, green: 0.20, blue: 0.25),  // Deep Red
                    Color(red: 0.90, green: 0.50, blue: 0.15),  // Deep Orange
                    Color(red: 0.20, green: 0.65, blue: 0.35),  // Deep Green
                    Color(red: 0.25, green: 0.50, blue: 0.85)   // Deep Blue
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}
