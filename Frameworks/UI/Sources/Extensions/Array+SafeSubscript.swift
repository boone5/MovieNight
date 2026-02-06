//
//  Array+SafeSubscript.swift
//  UI
//

import Foundation

public extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
