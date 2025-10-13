//
//  Array+Extensions.swift
//  ios
//
//  Created by Connor Black on 13/10/2025.
//

extension Array {
    /// Safe index access. Returns `nil` when out of bounds.
    /// Example: `let item = array[safe: index]`
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
